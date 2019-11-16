package com.redmoon.oa.util;

import java.io.File;

import cn.js.fan.util.ErrMsgException;
import com.jacob.activeX.ActiveXComponent;
import com.jacob.com.ComThread;
import com.jacob.com.Dispatch;

public class Word2PDF {
	// ========Error:文档转换失败：VariantChangeType failed
	// make the following two folders: 
	// "C:\Windows\SysWOW64\config\systemprofile\Desktop"
	// "C:\Windows\System32\config\systemprofile\Desktop". // 在windows2008下面必须手工添加此目录
	// Excel、Word转PDF时，异常com.jacob.com.ComFailException: Invoke of: SaveAs 
	// Office版本使用2007，因为2007提供了一个加载项：Microsoft Save as PDF 或 XPS，可将文档另存为PDF格式
	
	static final int wdDoNotSaveChanges = 0;// 不保存待定的更改。
	static final int wdFormatPDF = 17;// PDF 格式
	static final int ppSaveAsPDF = 32;// PDF 格式 
	
    public static boolean convert2PDF(String inputFile, String pdfFile) throws ErrMsgException {
		System.out.println("启动Word...");
		long start = System.currentTimeMillis();
		boolean isJacobSeted = false;
		ActiveXComponent app = null;
		try {
			// 此处为通过jacob实现转换
			ComThread.InitSTA();
			isJacobSeted = true;
			app = new ActiveXComponent("Word.Application");
			app.setProperty("Visible", false);

			Dispatch docs = app.getProperty("Documents").toDispatch();
			System.out.println("打开文档..." + inputFile);
			Dispatch doc = Dispatch.call(docs,//
					"Open", //
					inputFile,// FileName
					false,// ConfirmConversions
					true // ReadOnly
					).toDispatch();

			System.out.println("转换文档到PDF..." + pdfFile);
			File tofile = new File(pdfFile);
			if (tofile.exists()) {
				tofile.delete();
			}
			Dispatch.call(doc,//
					"SaveAs", //
					pdfFile, // FileName
					wdFormatPDF);

			Dispatch.call(doc, "Close", false);
			long end = System.currentTimeMillis();
			System.out.println("转换完成..用时：" + (end - start) + "ms.");
			return true; 
		}
		catch (NoClassDefFoundError e) {
			// java.lang.NoClassDefFoundError: Could not initialize class com.jacob.com.ComThread
			System.out.println("文档转换失败：jacob 尚未配置！");
			// e.printStackTrace();
			throw new ErrMsgException("文档转换失败：jacob 尚未配置！");
		}
		catch (Exception e) {
			System.out.println("文档转换失败：" + e.getMessage());
			// e.printStackTrace();
			throw new ErrMsgException("文档转换失败：" + e.getMessage());
		} finally {
			if (app != null) {
				app.invoke("Quit", wdDoNotSaveChanges);
			}
			if (isJacobSeted) {
				ComThread.Release();
			}
		}
    }
    
	public static void main(String[] args) {
		String filename = "f:/temp/测试文档.docx";
		String toFilename = filename + ".pdf";
		System.out.println("启动Word...");
		long start = System.currentTimeMillis();
		ActiveXComponent app = null;
		try {
			app = new ActiveXComponent("Word.Application");
			app.setProperty("Visible", false);

			Dispatch docs = app.getProperty("Documents").toDispatch();
			System.out.println("打开文档..." + filename);
			Dispatch doc = Dispatch.call(docs,//
					"Open", //
					filename,// FileName
					false,// ConfirmConversions
					true // ReadOnly
					).toDispatch();

			System.out.println("转换文档到PDF..." + toFilename);
			File tofile = new File(toFilename);
			if (tofile.exists()) {
				tofile.delete();
			}
			Dispatch.call(doc,//
					"SaveAs", //
					toFilename, // FileName
					wdFormatPDF);

			Dispatch.call(doc, "Close", false);
			long end = System.currentTimeMillis();
			System.out.println("转换完成..用时：" + (end - start) + "ms.");
		} catch (Exception e) {
			System.out.println("========Error:文档转换失败：" + e.getMessage());
		} finally {
			if (app != null)
				app.invoke("Quit", wdDoNotSaveChanges);
		}
	}
}
