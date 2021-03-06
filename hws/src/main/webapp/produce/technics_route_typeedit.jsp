<%--生产工艺类型编辑页面--%>
<%@ page contentType="text/html; charset=UTF-8"%><%@ include file="../pub/init.jsp"%>
<%@ page import="engine.dataset.*, engine.project.Operate"%><%!
  String op_add    = "op_add";
  String op_delete = "op_delete";
  String op_edit   = "op_edit";
  String op_search = "op_search";
  String op_over = "op_over";
%>
<html>
<head>
<link rel="stylesheet" href="../scripts/public.css" type="text/css">
</head>
<%String pageCode = "technics_route_type" ;
  if(!loginBean.hasLimits("technics_route_type", request, response))
    return;
  engine.erp.produce.B_TechnicsRouteType  b_TechnicsRouteTypeBean  =  engine.erp.produce.B_TechnicsRouteType.getInstance(request);
%>
<script language="javascript" src="../scripts/validate.js"></script>
<script>
function sumitForm(oper, row)
{
  lockScreenToWait("处理中, 请稍候！");
  form1.operate.value = oper;
  form1.submit();
}
</script>
<BODY oncontextmenu="window.event.returnValue=true">
<table WIDTH="100%" BORDER=0 cellspacing=0 cellpadding=0 CLASS="headbar"><tr>
    <TD NOWRAP align="center">工艺路线类型信息</TD>
  </tr></table>
<%String retu = b_TechnicsRouteTypeBean.doService(request, response);
  out.print(retu);
  if(retu.indexOf("location.href=")>-1)
    return;
  String curUrl = request.getRequestURL().toString();
  EngineDataSet ds = b_TechnicsRouteTypeBean.getOneTable();
  RowMap row = b_TechnicsRouteTypeBean.getRowinfo();
  boolean isEdit = b_TechnicsRouteTypeBean.isAdd ? loginBean.hasLimits(pageCode, op_add) : loginBean.hasLimits(pageCode, op_edit);//在增加的时候又增加操作，否则必须有修改权限
  String readonly = isEdit ? "" : "readonly";
%>
<form name="form1" action="<%=curUrl%>" method="POST" onsubmit="return false;" onKeyDown="return onInputKeyboard();">
  <INPUT TYPE="HIDDEN" NAME="operate" VALUE="">
  <table BORDER="0" cellpadding="1" cellspacing="3">
   <tr>
      <td noWrap class="tableTitle">&nbsp;工艺路线类型编号</td>
      <td noWrap class="td"><INPUT TYPE="TEXT" NAME="gylxlxbh" VALUE="<%=row.get("gylxlxbh")%>" SIZE="20" CLASS="edbox" <%=readonly%>></td>
    </tr>
    <tr>
      <td noWrap class="tableTitle">&nbsp;工艺路线类型名称<em>*</em></td>
      <td noWrap class="td"><INPUT TYPE="TEXT" NAME="gylxlxmc" VALUE="<%=row.get("gylxlxmc")%>" SIZE="20" MAXLENGTH="<%=ds.getColumn("gylxlxmc").getPrecision()%>" CLASS="edbox" <%=readonly%>>
      </td>
    </tr>
      <td colspan="2" noWrap class="tableTitle" align="center"><br><%if(isEdit){%>
        <input name="button" type="button" class="button" onClick="sumitForm(<%=Operate.POST%>);" value="保存(S)">
        <pc:shortcut key="s" script='<%="sumitForm("+ Operate.POST +",-1)"%>'/>
        <%}%><input name="button2" type="button" class="button" onClick="parent.hideFrameNoFresh()" value=" 关闭(X)">
         <pc:shortcut key="x" script='parent.hideFrameNoFresh()'/>
      </td>
    </tr>
  </table>
</form>
</BODY>
</Html>