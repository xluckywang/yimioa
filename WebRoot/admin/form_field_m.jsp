<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="cn.js.fan.util.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.redmoon.oa.flow.*" %>
<%@ page import="com.redmoon.oa.ui.*" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>表单字段管理</title>
    <link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css"/>
    <%@ include file="../inc/nocache.jsp" %>
    <script src="../inc/common.js"></script>
    <script src="../js/jquery-1.9.1.min.js"></script>
    <script src="../js/jquery-migrate-1.2.1.min.js"></script>

    <link href="../js/jquery-showLoading/showLoading.css" rel="stylesheet" media="screen"/>
    <script type="text/javascript" src="../js/jquery-showLoading/jquery.showLoading.js"></script>
    <script src="../js/jquery-alerts/jquery.alerts.js" type="text/javascript"></script>
    <script src="../js/jquery-alerts/cws.alerts.js" type="text/javascript"></script>
    <link href="../js/jquery-alerts/jquery.alerts.css" rel="stylesheet" type="text/css" media="screen"/>

    <script src="../js/jquery-ui/jquery-ui-1.10.4.min.js"></script>
    <link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/jquery-ui/jquery-ui-1.10.4.min.css"/>

    <link type="text/css" rel="stylesheet" href="../js/appendGrid/jquery.appendGrid-1.5.1.css"/>
    <script type="text/javascript" src="../js/appendGrid/jquery.appendGrid-1.5.1.js"></script>
</head>
<body>
<jsp:useBean id="fchar" scope="page" class="cn.js.fan.util.StrUtil"/>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
    if (!privilege.isUserPrivValid(request, "admin.flow")) {
        out.print(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
        return;
    }
    String formCode = ParamUtil.get(request, "code");
    FormDb fd = new FormDb();
    fd = fd.getFormDb(formCode);
    Vector v = fd.getFields();
%>
<%@ include file="form_edit_inc_menu_top.jsp" %>
<script>
    o("menu2").className = "current";
</script>
<div class="spacerH"></div>
<table width="60%" border="0" align="center">
    <tr>
        <td align="center"><strong><%=fd.getName()%>字段</strong></td>
    </tr>
</table>
<form id=form1 name=form1 action="form_field_m.jsp" method=post>
    <table id="tblFields" align="center">
    </table>
    <input type="hidden" name="code" value="<%=formCode%>"/>
</form>
<div style="margin-bottom:10px; margin-top: 10px; margin-left: 80px">
    1、“显示于手机”仅适用于智能模块
</div>
<div style="margin-bottom:10px; margin-top: 10px; margin-left: 80px">
    2、“比较”功能已被“验证规则”替代
</div>
<div style="text-align:center; margin-top:10px">
    <input type="button" class="btn" id="btnSubmit" value="确定"/>
</div>
</body>
<script>
    $(function () {
        // Initialize appendGrid
        $('#tblFields').appendGrid({
            // caption: '<%=fd.getName()%>字段',
            i18n: {
                append: '添加新行',
                rowDrag: '拖动',
                removeLast: '删除最后一行',
                insert: '添加一行在上方',
                moveUp: '上移',
                moveDown: '下移',
                remove: '删除'
            },
            initRows: 0,
            rowDragging: true,
            hideButtons: {
                append: true,
                remove: true,
                removeLast: true,
                insert: true,
                remove: true,
                removeLast: true
            },
            columns: [
                //  宽度隐藏比较字段操作
                {name: 'orders', display: '序号', type: 'hidden', ctrlAttr: {maxlength: 100}, ctrlCss: {width: '30px'}},
                // { name: 'fieldName', display: '字段名', type: 'text', ctrlAttr: { maxlength: 100, readonly: 'true', disabled:true }, ctrlCss: { width: '100px', border:'0'} },
                {
                    name: 'fieldName', display: '字段名',
                    type: "custom",
                    customBuilder: function (parent, idPrefix, name, uniqueIndex) {
                        // Create the content of custom type
                        var inputGroup = document.createElement("div");
                        inputGroup.classList.add("input-group");
                        parent.appendChild(inputGroup);
                        var inputGroupPrepend = document.createElement("div");
                        inputGroupPrepend.classList.add("input-group-prepend");
                        inputGroupPrepend.style.paddingLeft = "5px";
                        inputGroupPrepend.style.width = "100px";
                        inputGroup.appendChild(inputGroupPrepend);
                        var inputGroupPrependText = document.createElement("span");
                        inputGroupPrependText.id = "span_" + idPrefix + "_" + name + "_" + uniqueIndex;
                        inputGroupPrependText.classList.add("input-group-text");
                        inputGroupPrepend.appendChild(inputGroupPrependText);
                        var inputControl = document.createElement("input");
                        inputControl.id = idPrefix + "_" + name + "_" + uniqueIndex;
                        inputControl.name = inputControl.id;
                        inputControl.type = "hidden";
                        inputControl.classList.add("form-control");
                        inputGroup.appendChild(inputControl);
                    },
                    customGetter: function (idPrefix, name, uniqueIndex) {
                        var controlId = idPrefix + "_" + name + "_" + uniqueIndex;
                        return document.getElementById(controlId).value;
                    },
                    customSetter: function (idPrefix, name, uniqueIndex, value) {
                        var controlId = idPrefix + "_" + name + "_" + uniqueIndex;
                        document.getElementById(controlId).value = value;
                        document.getElementById("span_" + controlId).innerText = value;
                    }
                },
                {name: 'title', display: '字段描述', type: 'text', ctrlAttr: {maxlength: 50}, ctrlCss: {width: '100px', border: '0'}},
                {name: 'canNull', display: '允许空', type: 'select', ctrlOptions: {0: '否', 1: '是'}},
                {name: 'fieldType', display: '字段类型', type: 'text', ctrlAttr: {maxlength: 100, readonly: 'true', disabled: true}, ctrlCss: {width: '100px', border: '0'}},
                {name: 'ctlType', display: '控件类型', type: 'text', ctrlAttr: {maxlength: 10, readonly: 'true', disabled: true}, ctrlCss: {width: '180px', 'text-align': 'left', border: 0}, value: 0},
                {name: 'canQuery', display: '参与查询', type: 'select', ctrlOptions: {0: '否', 1: '是'}, ctrlAttr: {maxlength: 10}, ctrlCss: {width: '50px', 'text-align': 'right'}, value: 0},
                {name: 'isUnique', display: '唯一', type: 'select', ctrlOptions: {0: '否', 1: '是'}, ctrlAttr: {maxlength: 10, title: '字段值在表中是否唯一'}, ctrlCss: {width: '50px', 'text-align': 'right'}, value: 0},
                {name: 'canList', display: '列表显示', type: 'select', ctrlOptions: {0: '否', 1: '是'}, ctrlAttr: {maxlength: 10, title: '用于查询设计器、消息或邮件中显示表单概要信息'}, ctrlCss: {width: '50px', 'text-align': 'right'}, value: 0},
                {name: 'isMobileDisplay', display: '显示于手机', type: 'select', ctrlOptions: {0: '否', 1: '是'}, ctrlAttr: {maxlength: 10, title: '用于控制模块中的字段显示'}, ctrlCss: {width: '50px', 'text-align': 'right'}, value: 0},
                {name: 'width', display: '宽度', type: 'text', ctrlAttr: {maxlength: 10}, ctrlCss: {width: '50px', 'text-align': 'right'}, value: 0},
                {name: 'isHide', display: '隐藏', type: 'select', ctrlOptions: {0: '否', 1: '查看及编辑时', 2: '仅编辑时'}, ctrlAttr: {maxlength: 10}, ctrlCss: {width: '50px', 'text-align': 'right'}, value: 0},
                {name: 'morethanMode', display: '比较', type: 'select', ctrlOptions: {'': '无', '>': '>', '>=': '>=', '<': '<', '<=': '<=', '=': '='}, ctrlAttr: {maxlength: 10}, ctrlCss: {width: '50px', 'text-align': 'right'}, value: 0},
                <%
                    StringBuffer sb = new StringBuffer();
                    sb.append("'':'无'");
                    Iterator ir = v.iterator();
                    while (ir.hasNext()) {
                        FormField ff = (FormField)ir.next();
                        if (ff.getFieldType() == FormField.FIELD_TYPE_DATETIME || ff.getFieldType() == FormField.FIELD_TYPE_DATE || ff.getFieldType() == FormField.FIELD_TYPE_INT || ff.getFieldType()==FormField.FIELD_TYPE_LONG
                          || ff.getFieldType()==FormField.FIELD_TYPE_PRICE || ff.getFieldType()==FormField.FIELD_TYPE_DOUBLE || ff.getFieldType()==FormField.FIELD_TYPE_DOUBLE) {
                          StrUtil.concat(sb, ",", "'" + ff.getName() + "':'" + ff.getTitle() + "'");
                        }
                    }
              %>
                {name: 'moreThan', display: '字段', type: 'select', ctrlOptions: {<%=sb%>}, ctrlAttr: {maxlength: 10}, ctrlCss: {width: '100px', 'text-align': 'right'}, value: 0},
                {name: 'name', type: 'hidden', value: ''}
            ]
        });

        <%
           JSONArray arr = new JSONArray();
           ir = v.iterator();
           while (ir.hasNext()) {
                FormField ff = (FormField)ir.next();
                JSONObject json = new JSONObject();
                json.put("orders", ff.getOrders());
                json.put("fieldName", ff.getName());
                json.put("title", ff.getTitle());
                json.put("canNull", ff.isCanNull()?1:0);
                json.put("fieldType", ff.getFieldTypeDesc());
                json.put("ctlType", FormField.getTypeDesc(ff.getType(), ff.getMacroType()));
                json.put("canQuery", ff.isCanQuery()?1:0);
                json.put("canList", ff.isCanList()?1:0);

                json.put("isUnique", ff.isUnique()?1:0);

                json.put("isMobileDisplay", ff.isMobileDisplay()?1:0);
                json.put("width", ff.getWidth());
                json.put("isHide", ff.getHide());
                json.put("morethanMode", ff.getMorethanMode());
                json.put("moreThan", ff.getMoreThan());

                json.put("name", ff.getName());

                arr.put(json);
           }
        %>
        
        // console.log('<%=arr.toString()%>');

        $(function () {
            $('#tblFields').appendGrid('load', <%=arr%>);
        });

        $('#btnSubmit').button().click(function () {
            $.ajax({
                type: "post",
                url: "<%=request.getContextPath()%>/form/updateFormField.do",
                contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
                data: $(document.forms[0]).serialize(),
                dataType: "html",
                beforeSend: function (XMLHttpRequest) {
                    $("body").showLoading();
                },
                success: function (data, status) {
                    data = $.parseJSON(data);
                    jAlert(data.msg, "提示");
                },
                complete: function (XMLHttpRequest, status) {
                    $("body").hideLoading();
                },
                error: function (XMLHttpRequest, textStatus) {
                    // 请求出错处理
                    alert(XMLHttpRequest.responseText);
                }
            });
        });
    });

</script>
</html>
