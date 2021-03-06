package com.redmoon.forum.miniplugin.weather;

import org.apache.log4j.Logger;
import cn.js.fan.web.SkinUtil;
import java.util.Locale;
import javax.servlet.http.HttpServletRequest;
import cn.js.fan.util.ResBundle;
import com.redmoon.forum.plugin.PluginUnit;
import com.redmoon.forum.plugin.PluginMgr;
import cn.js.fan.base.ISkin;
import com.redmoon.forum.ui.*;
import java.util.Iterator;
import com.redmoon.forum.miniplugin.MiniPluginMgr;
import com.redmoon.forum.miniplugin.MiniPluginUnit;

/**
 *
 * <p>Title: 杂项的显示</p>
 *
 * <p>Description: </p>
 *
 * <p>Copyright: Copyright (c) 2005</p>
 *
 * <p>Company: </p>
 *
 * @author not attributable
 * @version 1.0
 */
public class WeatherSkin implements ISkin {
    public static final String CODE = "weather";
    static Logger logger = Logger.getLogger(WeatherSkin.class.getName());
    public static String resource = null;

    public WeatherSkin() {
    }

    public static Skin getSkin(String skinCode) {
        PluginMgr pm = new PluginMgr();
        PluginUnit pu = pm.getPluginUnit(CODE);
        Iterator ir = pu.getSkins().iterator();
        while (ir.hasNext()) {
            Skin skin = (Skin)ir.next();
            if (skin.getCode().equals(skinCode))
                return skin;
        }
        return null;
    }

    public static String getSkinPath(String skinCode) {
        Skin skin = getSkin(skinCode);
        if (skin==null)
            return "default";
        else
            return skin.getPath();
    }

     public static String getResource() {
        if (resource==null) {
            MiniPluginMgr pm = new MiniPluginMgr();
            MiniPluginUnit pu = pm.getMiniPluginUnit(CODE);
            return pu.getResource();
        }
        return resource;
    }

    public static String LoadString(HttpServletRequest request, String key) {
        Locale locale = SkinUtil.getLocale(request);
        ResBundle rb = new ResBundle(getResource(), locale);
        if (rb == null)
            return "";
        else {
            String str = "";
            try {
                str = rb.get(key);
            }
            catch (Exception e) {
                logger.error("LoadString:" + key + " " + e.getMessage());
            }
            return str;
        }
    }

    public String LoadStr(HttpServletRequest request, String key) {
        return LoadString(request, key);
    }
}
