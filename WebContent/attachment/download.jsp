<%response.setDateHeader("Expires", 0); //Causes the proxy cache to see the page as "stale"%>

<%@page import="java.net.*"%>
<%@page import="com.sogou.qadev.service.cynthia.bean.Attachment"%>
<%@page import="com.sogou.qadev.service.login.bean.Key"%>
<%@page import="com.sogou.qadev.service.cynthia.factory.DataAccessFactory"%>
<%@page import="com.sogou.qadev.service.cynthia.service.DataAccessSession"%>
<%@page import="com.sogou.qadev.service.cynthia.bean.UUID"%>
<%@page import="com.sohu.rd.td.util.db.ItemBaseUtil"%>
<%@page import="com.sogou.qadev.service.cynthia.util.ConfigUtil"%>

<%
	//parse request
String	method	= request.getParameter("method");

String idStr = request.getParameter("id");
UUID id = DataAccessFactory.getInstance().createUUID(idStr);

DataAccessSession das = null;
if(session == null || session.getAttribute("kid") == null || session.getAttribute("key") == null)
{
	 das = DataAccessFactory.getInstance().getSysDas();
}
else
{
	long keyId = (Long)session.getAttribute("kid");
	Key key = (Key)session.getAttribute("key");
	das = DataAccessFactory.getInstance().createDataAccessSession(key.getUsername(), keyId);
}

Attachment attachment = das.queryAttachment(id, true);
if ( attachment == null )
{
	response.setContentType("text/html; charset=utf-8");
%>
	ERROR:<br/>
	Sorry, can't get attachment file info<br/>
	Meybe you didn't pass the passport of qadev.rd.sogou or can't find attachment.
	<%
	return;
}

if ( "info".equalsIgnoreCase(method) )
{
	response.setContentType("application/xml; charset=utf-8");
	%>
<?xml version='1.0' encoding='UTF-8'?>
<attachment id='<%=attachment.getId() %>' name=<%=ItemBaseUtil.toSafeSQLString(attachment.getName()) %> createUser=<%=ItemBaseUtil.toSafeSQLString(attachment.getCreateUser()) %> createTime=<%=ItemBaseUtil.toSafeSQLString(attachment.getCreateTime()) %> fileSize='<%=attachment.getSize() %>' />
	<%
	return;
}
else if ( "download".equalsIgnoreCase(method) )
{
	response.addHeader("Content-Disposition","attachment;filename="+ new String( attachment.getName().getBytes("gb2312"), "ISO8859-1" ) );
	response.setContentType("application/x-attachment");

	try
	{
		out.clear();
		response.getOutputStream().write(attachment.getData());
	}catch(Exception e)
	{
		e.printStackTrace();
	}
}
%>