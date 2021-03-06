<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="com.redmoon.oa.emailpop3.*"%>
<%@ page import="cn.js.fan.web.*"%>
<%@ page import="cn.js.fan.util.*"%>
<%@ page import="cn.js.fan.mail.*"%>
<%@ page import="java.util.*"%>
<%@page import="org.json.JSONObject"%>
<% 
	int draftId = ParamUtil.getInt(request,"draftId",-1);
	String type = ParamUtil.get(request,"type");
%>
<html>
<head>
<title>取邮件</title>
<link href="../common.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript" src="../js/jquery1.7.2.min.js"></script>
<script src="../js/jquery-alerts/jquery.alerts.js" type="text/javascript"></script>
<script src="../js/jquery-alerts/cws.alerts.js" type="text/javascript"></script>
<link href="../js/jquery-alerts/jquery.alerts.css" rel="stylesheet"	type="text/css" media="screen" />
<%@ include file="../inc/nocache.jsp" %>
</head>
<style>
	.loading{
	display: none;
	position: fixed;
	z-index:1801;
	top: 45%;
	left: 45%;
	width: 100%;
	margin: auto;
	height: 100%;
	}
	.SD_overlayBG2 {
	background: #FFFFFF;
	filter: alpha(opacity = 20);
	-moz-opacity: 0.20;
	opacity: 0.20;
	z-index: 1500;
	}
	.treeBackground {
	display: none;
	position: absolute;
	top: -2%;
	left: 0%;
	width: 100%;
	margin: auto;
	height: 200%;
	background-color: #EEEEEE;
	z-index: 1800;
	-moz-opacity: 0.8;
	opacity: .80;
	filter: alpha(opacity = 80);
	}
</style>
<body leftmargin="0" topmargin="5">
<div id="treeBackground" class="treeBackground"></div>
<div id='loading' class='loading'><img src='../images/loading.gif'></div>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>

<jsp:useBean id="fchar" scope="page" class="cn.js.fan.util.StrUtil"/>
<%
boolean re = false;
MailMsgMgr mmm = new MailMsgMgr();
try {%>
	<script>
		$(".treeBackground").addClass("SD_overlayBG2");
		$(".treeBackground").css({"display":"block"});
		$(".loading").css({"display":"block"});
	</script>
	<%
	if(draftId != -1){
		re = mmm.modify(application, request);
	}else{
		re = mmm.add(application, request);
	}
}
catch (ErrMsgException e) {
	out.print(StrUtil.jAlert_Back(e.getMessage(),"提示"));
	return;
}
if (re) {
	%>
	<script>
		$(".loading").css({"display":"none"});
		$(".treeBackground").css({"display":"none"});
		$(".treeBackground").removeClass("SD_overlayBG2");
	</script>
	<%
	MailMsgDb mmd = mmm.getMailMsgDb();
	EmailPop3Db epd = new EmailPop3Db();
	epd = epd.getEmailPop3Db(privilege.getUser(request), mmd.getEmailAddr());
	draftId = mmd.getId();
	if(draftId != -1){
		if(type.equals("")){
			response.sendRedirect("send_mail.jsp?emailId=" + epd.getId() + "&draftId=" + mmd.getId());
		}else{
			response.sendRedirect("mail_edit.jsp?emailId=" + epd.getId() + "&draftId=" + mmd.getId());
		}
	}else{
		response.sendRedirect("list_box.jsp?id=" + epd.getId() + "&box=" + MailMsgDb.TYPE_DRAFT + "&sender=" + mmm.getMailMsgDb().getSender());
	}
}
%>
</body>
</html>
