<%--生产工序名称列表--%>
<%@ page contentType="text/html; charset=UTF-8"%><%@ include file="../pub/init.jsp"%>
<%@ page import="engine.dataset.*,engine.project.Operate"%><%!
  String op_add    = "op_add";
  String op_delete = "op_delete";
  String op_edit   = "op_edit";
  String op_search = "op_search";
  String op_over = "op_over";
%>
<%String pageCode = "technics_name" ;
  if(!loginBean.hasLimits("technics_name", request, response))
    return;
  engine.erp.produce.B_TechnicsName b_TechnicsNameBean  =  engine.erp.produce.B_TechnicsName.getInstance(request);
  String retu = b_TechnicsNameBean.doService(request, response);
  if(retu.indexOf("location.href=")>-1)
    return;
%>
<html>
<head>
<title></title>
<link rel="stylesheet" href="../scripts/public.css" type="text/css">
</head>
<script language="javascript" src="../scripts/validate.js"></script>
<script language="javascript" src="../scripts/rowcontrol.js"></script>
<script language="javascript" src="../scripts/tabcontrol.js"></script>

<SCRIPT LANGUAGE="javascript">
  function sumitForm(oper, row)
  {
    lockScreenToWait("处理中, 请稍候！");
    form1.operate.value = oper;
    form1.rownum.value = row;
    form1.submit();
  }
  function showInterFrame(oper, rownum){
   var url = "technics_nameedit.jsp?operate="+oper+"&rownum="+rownum;
   document.all.interframe1.src = url;
   showFrame('detailDiv',true,"",true);
 }

 function hideInterFrame()//隐藏FRAME
 {
   lockScreenToWait("处理中, 请稍候！");
   hideFrame('detailDiv');
   form1.submit();
 }
 function hideFrameNoFresh(){
   hideFrame('detailDiv');
  }
</SCRIPT>
<BODY oncontextmenu="window.event.returnValue=true">
<TABLE WIDTH="100%" BORDER=0 CELLSPACING=0 CELLPADDING=0 CLASS="headbar">
  <TR>
    <TD colspan="6" align="center" NOWRAP>工序名称设置</TD>
  </TR>
</TABLE>
<%
  EngineDataSet list = b_TechnicsNameBean.getOneTable();
  String curUrl = request.getRequestURL().toString();
  engine.project.LookUp workProduceBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_WORK_PROCEDURE);
%>
<form name="form1" method="post" action="<%=curUrl%>" onsubmit="return false;" onKeyDown="return onInputKeyboard();">
  <INPUT TYPE="HIDDEN" NAME="operate" VALUE="">
  <INPUT TYPE="HIDDEN" NAME="rownum" VALUE="">
  <TABLE WIDTH="90%" BORDER=0 CELLSPACING=0 CELLPADDING=0 align="center">
    <TR>
    <td class="td" nowrap>
     <%String key = "ppdfsgg"; pageContext.setAttribute(key, list);
       int iPage = loginBean.getPageSize(); String pageSize = ""+iPage;%>
      <pc:dbNavigator dataSet="<%=key%>" pageSize="<%=pageSize%>"/>
</td>
      <TD align="right"><%if(b_TechnicsNameBean.retuUrl!=null){%><input name="button2222232" type="button" align="Right"
      class="button" onClick="location.href='<%=b_TechnicsNameBean.retuUrl%>'" value=" 返回(C)"border="0">
         <% String back ="location.href='"+b_TechnicsNameBean.retuUrl+"'" ;%>
         <pc:shortcut key="c" script='<%=back%>'/><%}%></TD>
    </TR>
  </TABLE>
  <table id="tableview1" width="90%" border="0" cellspacing="1" cellpadding="1" class="table" align="center">
    <COLGROUP valign="middle" span="5">
    <COLGROUP width=60 align="center">
    <tr class="tableTitle">
      <td width="45"><%if(loginBean.hasLimits(pageCode, op_add)){%><input name="image" class="img" type="image" title="新增(A)" onClick="showInterFrame(<%=Operate.ADD%>,-1)" src="../images/add.gif" border="0">
      <pc:shortcut key="a" script='<%="showInterFrame("+ Operate.ADD +",-1)"%>'/><%}%></td>
      <td nowrap>工序编号</td>
      <td nowrap>工序名称</td>
      <td nowrap>所属工段</td>
      <td nowrap>工序描述</td>
    </tr>
    <%list.first();
      int i=0;
      for(; i<list.getRowCount(); i++)
      {
    %>
    <tr onDblClick="showInterFrame(<%=Operate.EDIT%>,<%=list.getRow()%>)">
       <td class="td"><input name="image2" class="img" type="image" title="修改" onClick="showInterFrame(<%=Operate.EDIT%>,<%=list.getRow()%>)" src="../images/edit.gif" border="0">
      <%if(loginBean.hasLimits(pageCode, op_delete)){%><input name="image" class="img" type="image" title="删除" onClick="if(confirm('是否删除该记录？')) sumitForm(<%=Operate.DEL%>,<%=list.getRow()%>)" src="../images/del.gif" border="0">
      <%}%></td>
      <td class="td"><%=list.getValue("gybh")%></td>
      <td class="td"><%=list.getValue("gymc")%></td>
      <td class="td"><%=workProduceBean.getLookupName(list.getValue("gxfdid"))%></td>
      <td class="td"><%=list.getValue("gyms")%></td>
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
      <td class="td"></td>
    </tr>
    <%}%>
  </table>
  <SCRIPT LANGUAGE="javascript">initDefaultTableRow('tableview1',1);</SCRIPT>
</form><%out.print(retu);%>
<div class="queryPop" id="detailDiv" name="detailDiv">
  <div class="queryTitleBox" align="right"><A onClick="hideFrame('detailDiv')" href="#"><img src="../images/closewin.gif" border=0></A></div>
  <TABLE cellspacing=0 cellpadding=0 border=0>
    <TR>
      <TD><iframe id="interframe1" src="" width="230" height="300" marginWidth="0" marginHeight="0" frameBorder="0" noResize scrolling="no"></iframe>
      </TD>
    </TR>
  </TABLE>
</div>
</body>
</html>