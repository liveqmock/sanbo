<%@ page contentType="text/html; charset=UTF-8" %><%@ include file="../pub/init.jsp"%>
<%@ page import="engine.dataset.*"%>
<html>
<head>
<title>地区列表</title>
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../scripts/public.css" type="text/css">
</head>
<%!
  String op_add    = "op_add";
  String op_delete = "op_delete";
  String op_edit   = "op_edit";
  String op_search = "op_search";
  String pageCode = "machine_tool";
%>
<%if(!loginBean.hasLimits("machine_tool", request, response))
    return;
engine.erp.equipment.B_MachineTools machineToolsBean  =   engine.erp.equipment.B_MachineTools.getInstance(request);
engine.project.LookUp deptBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_DEPT_LIST);
%>
<script language="javascript" src="../scripts/validate.js"></script>

<script language="javascript">
function sumitForm(oper, row)
{
  lockScreenToWait("处理中, 请稍候！");
  form1.operate.value = oper;
  form1.rownum.value = row;
  form1.submit();
}
function showInterFrame(oper, rownum){
    var url = "machine_tool_edit.jsp?operate="+oper+"&rownum="+rownum;
    document.all.interframe1.src = url;
    showFrame('detailDiv',true,"",true);
  }

  function hideInterFrame()//隐藏FRAME
  {
    hideFrame('detailDiv');
    form1.submit();
  }
  function hideFrameNoFresh(){
    hideFrame('detailDiv');
  }
</script>
<BODY oncontextmenu="window.event.returnValue=true">
<TABLE WIDTH="100%" BORDER=0 CELLSPACING=0 CELLPADDING=0 CLASS="headbar"><TR>
    <TD NOWRAP align="center">设备档案</TD>
  </TR></TABLE>
<%String retu = machineToolsBean.doService(request, response);
  out.print(retu);
  if(retu.indexOf("location.href=")>-1)
    return;

  EngineDataSet list = machineToolsBean.getOneTable();
  String curUrl = request.getRequestURL().toString();
%>
<form name="form1" method="post" action="<%=curUrl%>" onsubmit="return false;" onKeyDown="return onInputKeyboard();" >
  <INPUT TYPE="HIDDEN" NAME="operate" VALUE="">
  <INPUT TYPE="HIDDEN" NAME="rownum" VALUE="">
  <table id="tbcontrol" width="100%" border="0" cellspacing="1" cellpadding="1" align="center">
    <tr>
      <td class="td" nowrap><%String key = "datasetlist"; pageContext.setAttribute(key, list);
       int iPage = loginBean.getPageSize(); String pageSize = String.valueOf(iPage);%>
      <pc:dbNavigator dataSet="<%=key%>" pageSize="<%=pageSize%>"/></td>
      <td class="td" align="right"><%if(machineToolsBean.retuUrl!=null){%><input name="button22" type="button" class="button" onClick="location.href='<%=machineToolsBean.retuUrl%>'" value=" 返回 "><%}%></td>
    </tr>
  </table>
  <table id="tableview1" width="100%" border="0" cellspacing="1" cellpadding="1" class="table" align="center">
    <tr class="tableTitle">
      <td nowrap>设备编号</td>
      <td nowrap>型号</td>
      <td nowrap>主要使用部门</td>
      <td width=55 align="center" nowrap><input name="image" class="img" type="image" title="新增(ALT+A)" onClick="showInterFrame(<%=machineToolsBean.ADD%>,-1)" src="../images/add.gif" border="0">
      <pc:shortcut key="a" script='<%="showInterFrame("+ machineToolsBean.ADD +",-1)"%>'/>
      </td>
    </tr>
    <%list.first();
      int i=0;
      for(; i<list.getRowCount(); i++)   {
    %>
    <tr onDblClick="showInterFrame(<%=machineToolsBean.EDIT%>,<%=i%>)">
      <td class="td" nowrap><%=list.getValue("code")%></td>
      <td class="td" nowrap><%=list.getValue("tool_type")%></td>
      <td class="td" nowrap><%=deptBean.getLookupName(list.getValue("deptid"))%></td>
      <td class="td">
        <input name="image" class="img" type="image" title="修改" onClick="showInterFrame(<%=machineToolsBean.EDIT%>,<%=i%>)" src="../images/edit.gif" border="0">
        <input name="image" class="img" type="image" title="删除" onClick="if(confirm('是否删除该记录？')) sumitForm(<%=machineToolsBean.DEL%>,<%=i%>)" src="../images/del.gif" border="0">
      </td>
    </tr>
    <%  list.next();
      }
      for(; i < loginBean.getPageSize(); i++){
    %>
		<tr>
      <td class="td">&nbsp;</td>
      <td class="td"></td>
      <td class="td"></td>
      <td class="td"></td>
		</tr>
    <%}%>
  </table>
	<script LANGUAGE="javascript">initDefaultTableRow('tableview1',1);</script>
  </form>
  <div class="queryPop" id="detailDiv" name="detailDiv">
  <div class="queryTitleBox" align="right"><A onClick="hideFrame('detailDiv')" href="#"><img src="../images/closewin.gif" border=0></A></div>
  <TABLE cellspacing=0 cellpadding=0 border=0>
    <TR>
      <TD><iframe id="interframe1" src="" width="335" height="180" marginWidth="0" marginHeight="0" frameBorder="0" noResize scrolling="no"></iframe>
      </TD>
    </TR>
  </TABLE>
</div>
</body>
</html>
