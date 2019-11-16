package com.redmoon.weixin.util;

import cn.js.fan.util.StrUtil;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;

/**
 * Created by fgf on 2018/12/15.
 */

public class HttpPostFileUtil {
    private URL url;
    private HttpURLConnection conn;
    private String boundary = "--------httppost123";
    private HashMap<String, Object> textParams = new HashMap<String, Object>();
    private HashMap<String, File> fileparams = new HashMap<String, File>();
    private DataOutputStream outputStream;

    public HttpPostFileUtil(String url) throws MalformedURLException {
        this.url = new URL(url);
    }

    /**
     * 重新设置要请求的服务器地址，即上传文件的地址。
     *
     * @param url
     * @throws Exception
     */
    public void setUrl(String url) throws Exception {
        this.url = new URL(url);
    }

    /**
     * 增加一个普通字符串数据到form表单数据中
     *
     * @param name
     * @param value
     */
    public void addParameter(String name, Object value) {
        textParams.put(name, value);
    }

    /**
     * 增加一个文件到form表单数据中
     *
     * @param name
     * @param value
     */
    public void addParameter(String name, File value) {
        fileparams.put(name, value);
    }

    /**
     * 清空所有已添加的form表单数据
     */
    public void clearAllParameters() {
        textParams.clear();
        fileparams.clear();
    }

    /**
     * 发送数据到服务器，返回一个字节包含服务器的返回结果的数组
     *
     * @return
     * @throws Exception
     */
    public String send() throws IOException {
        initConnection();
        conn.connect();
        outputStream = new DataOutputStream(conn.getOutputStream());
        writeFileParams();
        writeStringParams();
        paramsEnd();
        int code = conn.getResponseCode();
        if (code == 200 || code==500) {
            InputStream in = conn.getInputStream();
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] buf = new byte[1024 * 8];
            int len;
            while ((len = in.read(buf)) != -1) {
                out.write(buf, 0, len);
            }
            conn.disconnect();
            String s = new String(out.toByteArray(), "utf-8");
            return s;
        }
        return null;
    }

    /**
     * 文件上传的connection的一些必须设置
     *
     * @throws Exception
     */
    private void initConnection() throws IOException {
        conn = (HttpURLConnection) this.url.openConnection();
        conn.setDoOutput(true);
        conn.setUseCaches(false);
        conn.setConnectTimeout(10000); // 连接超时为10秒
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
    }

    /**
     * 普通字符串数据
     *
     * @throws Exception
     */
    private void writeStringParams() throws IOException {
        Set<String> keySet = textParams.keySet();
        for (Iterator<String> it = keySet.iterator(); it.hasNext(); ) {
            String name = it.next();
            Object ov = textParams.get(name);

            if (ov instanceof String[]) {
                String[] ary = (String[])ov;
                for (String val : ary) {
                    outputStream.writeBytes("--" + boundary + "\r\n");
                    outputStream.writeBytes("Content-Disposition: form-data; name=\"" + name + "\"\r\n");
                    outputStream.writeBytes("\r\n");
                    outputStream.writeBytes(encode(val) + "\r\n");
                }
            } else {
                outputStream.writeBytes("--" + boundary + "\r\n");
                outputStream.writeBytes("Content-Disposition: form-data; name=\"" + name + "\"\r\n");
                outputStream.writeBytes("\r\n");
                outputStream.writeBytes(encode((String)ov) + "\r\n");
            }
        }
    }

    /**
     * 文件数据
     *
     * @throws Exception
     */
    private void writeFileParams() throws IOException {
        Set<String> keySet = fileparams.keySet();
        for (Iterator<String> it = keySet.iterator(); it.hasNext(); ) {
            String name = it.next();
            File file = fileparams.get(name);

            outputStream.writeBytes("--" + boundary + "\r\n");
            // outputStream.writeBytes("Content-Disposition: form-data; name=\"" + name + "\"; filename=\"" + StrUtil.UrlEncode(file.getName()) + "\"\r\n");
            outputStream.writeBytes("Content-Disposition: form-data; name=\"" + name + "\"; filename=\"license.dat\"\r\n");
            outputStream.writeBytes("Content-Type: " + getContentType(file) + "\r\n");
            outputStream.writeBytes("\r\n");

            outputStream.write(getBytes(file));

            outputStream.writeBytes("\r\n");
        }
    }

    /**
     * 获取文件的上传类型，图片格式为image/png,image/jpeg等。非图片为application /octet-stream
     *
     * @param f
     * @return
     * @throws Exception
     */
    private String getContentType(File f) {
        return "application/octet-stream";
    }

    /**
     * 把文件转换成字节数组
     *
     * @param f
     * @return
     * @throws Exception
     */
    private byte[] getBytes(File f) throws IOException {
        FileInputStream in = new FileInputStream(f);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] b = new byte[1024];
        int n;
        while ((n = in.read(b)) != -1) {
            out.write(b, 0, n);
        }
        in.close();
        return out.toByteArray();
    }

    /**
     * 添加结尾数据
     *
     * @throws Exception
     */
    private void paramsEnd() throws IOException {
        outputStream.writeBytes("--" + boundary + "--" + "\r\n");
        outputStream.writeBytes("\r\n");
    }

    /**
     * 对包含中文的字符串进行转码，此为UTF-8。服务器那边要进行一次解码
     *
     * @param value
     * @return
     * @throws Exception
     */
    private String encode(String value) {
        // 防止中文乱码
        return StrUtil.UTF8ToUnicode(value);
/*
        // controller接收的时候，不仅中文，其它也会变成乱码
        try {
            return URLEncoder.encode(value, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return value;*/
    }
}

