<%--采购合同列表--%>
<%@page contentType="text/html; charset=UTF-8" %><%@ include file="../pub/init.jsp"%>
<%@ page import="engine.dataset.*,engine.action.Operate,java.math.BigDecimal,java.util.ArrayList,engine.html.*"%>
<%!
  String op_add    = "op_add";
  String op_delete = "op_delete";
  String op_edit   = "op_edit";
  String op_search = "op_search";
  String op_cancel   = "op_cancel";
  String op_over = "op_over";
  String op_item ="op_item";
%>
<%
  engine.erp.buy.xixing.B_BuyOrder buyOrderBean = engine.erp.buy.xixing.B_BuyOrder.getInstance(request);
  String pageCode = "buy_order";
  if(!loginBean.hasLimits(pageCode, request, response))
    return;
  boolean hasSearchLimit = loginBean.hasLimits(pageCode, op_search);
  boolean bhasSearchLimit = loginBean.hasLimits(pageCode, op_item);
  String SYS_APPROVE_ONLY_SELF =buyOrderBean.SYS_APPROVE_ONLY_SELF;//提交审批是否只有制单人可以提交,1=仅制单人可提交,0=有权限人可提交
  boolean isApproveOnly = SYS_APPROVE_ONLY_SELF.equals("1") ? true : false;//true仅制单人可提交
%>
<html>
<head>
<title></title>
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<META HTTP-EQUIV="Cache-Cont...000000rol" CONTENT="no-cache">
<meta http-equiv="refresh" content="60">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../scripts/public.css" type="text/css">
</head>
<script language="javascript" src="../scripts/validate.js"></script>
<script language="javascript" src="../scripts/frame.js"></script>
<script language="javascript">
function toDetail(){
  parent.location.href='buy_order_edit.jsp';
}
function showDetail(masterRow){
  selectRow();
  lockScreenToWait("处理中, 请稍候！");
  parent.bottom.location.href='buy_order_bottom.jsp?operate=<%=buyOrderBean.SHOW_DETAIL%>&rownum='+masterRow;
  unlockScreenWait();
}
function sumitForm(oper, row)
{
  lockScreenToWait("处理中, 请稍候！");
  form1.operate.value = oper;
  form1.rownum.value = row;
  form1.submit();
}
//客户编码
function customerCodeSelect(obj)
{
    ProvideCodeChange(document.all['prod'], obj.form.name,'srcVar=dwdm&srcVar=dwtxid&srcVar=dwmc','fieldVar=dwdm&fieldVar=dwtxid&fieldVar=dwmc',obj.value);
}
//客户名称
function customerNameSelect(obj)
{
  ProvideNameChange(document.all['prod'], obj.form.name,'srcVar=dwdm&srcVar=dwtxid&srcVar=dwmc','fieldVar=dwdm&fieldVar=dwtxid&fieldVar=dwmc',obj.value);
}
</script>
<BODY oncontextmenu="window.event.returnValue=true">
<iframe id="prod" src="" width="95%" height=25 marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=no style="display:none"></iframe>
<TABLE WIDTH="100%" BORDER=0 CELLSPACING=0 CELLPADDING=0 CLASS="headbar"><TR>
    <TD NOWRAP align="center">采购订单</TD>
  </TR></TABLE>
<%String retu = buyOrderBean.doService(request, response);
  if(retu.indexOf("toDetail();")>-1 || retu.indexOf("location.href=")>-1)
  {
    out.print(retu);
    return;
  }
  engine.project.LookUp deptBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_DEPT);
  engine.project.LookUp corpBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_CORP);
  engine.project.LookUp prodBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_PRODUCT);
  engine.project.LookUp personBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_PERSON);
  EngineDataSet list = buyOrderBean.getMaterTable();
  EngineDataSet detail = buyOrderBean.getDetailTable();
  HtmlTableProducer table = buyOrderBean.masterProducer;
  String curUrl = request.getRequestURL().toString();
  String loginId = buyOrderBean.loginId;
%>
<form name="form1" method="post" action="<%=curUrl%>" onsubmit="return false;" onKeyDown="return onInputKeyboard();">
  <INPUT TYPE="HIDDEN" NAME="operate" VALUE="">
  <INPUT TYPE="HIDDEN" NAME="rownum" VALUE="">
  <table id="tbcontrol" width="95%" border="0" cellspacing="1" cellpadding="1" align="center">
    <tr>
      <td class="td" nowrap><%String key = "datasetlist"; pageContext.setAttribute(key, list);
       int iPage = loginBean.getPageSize()-7; String pageSize = String.valueOf(iPage);%>
      <pc:dbNavigator dataSet="<%=key%>" pageSize="<%=pageSize%>"/></td>


             <td class="td" nowrap align="right"><%if(bhasSearchLimit){%><input name="search55" type="button" class="button" onClick="showInterFrame()" value=" 默认条款(M)" onKeyDown="return getNextElement();">
        <pc:shortcut key="M" script='showInterFrame()'/><%}%>



      <%if(hasSearchLimit){%><input name="search2" type="button" class="button" onClick="showFixedQuery()" value=" 查询(Q)" onKeyDown="return getNextElement();">
        <pc:shortcut key="q" script='showFixedQuery()'/><%}%>
        <%if(buyOrderBean.retuUrl!=null){%><input name="button22" type="button" class="button" onClick="parent.location.href='<%=buyOrderBean.retuUrl%>'" value=" 返回(C)" onKeyDown="return getNextElement();">
        <% String back ="parent.location.href='"+buyOrderBean.retuUrl+"'" ;%>
         <pc:shortcut key="c" script='<%=back%>'/><%}%></td>
    </tr>
  </table>
  <table id="tableview1" width="95%" border="0" cellspacing="1" cellpadding="1" class="table" align="center">
    <tr class="tableTitle">
      <td nowrap align="center"><%if(loginBean.hasLimits(pageCode, op_add)){%>
        <input name="image" class="img" type="image" title="新增(A)" onClick="sumitForm(<%=Operate.ADD%>,-1)" src="../images/add_big.gif" border="0">
      <pc:shortcut key="a" script='<%="sumitForm("+ Operate.ADD +",-1)"%>'/><%}%></td>
      <%table.printTitle(pageContext, "height='20'");%>
    </tr>
    <%BigDecimal t_zsl = new BigDecimal(0), t_zje = new BigDecimal(0);
     list.first();
      int i=0;
      int count = list.getRowCount();

      StringBuffer sb=new StringBuffer();
      for(; i<count; i++){
        int j;
        int isBuyDone=-1,isStoreDone=-1;   //isBuyDone :进货；isStoreDone：入库 0表示‘没有’，1表示‘部分’，2表示‘全部’
        double sjjhl=0.0,sjrkl=0.0,tempHssl=0.0;
        list.goToRow(i);
        synchronized(detail){
          buyOrderBean.openDetailTable(false);
          detail.first();
          for(j=0;j<detail.getRowCount();j++){
            tempHssl = Double.parseDouble(detail.getValue("hssl").trim().length()>0?detail.getValue("hssl"):"0");
            sjjhl = Double.parseDouble(detail.getValue("sjjhl").trim().length()>0?detail.getValue("sjjhl"):"0");
            if(sjjhl == 0 && isBuyDone == 2){isBuyDone = 1; break;}
            if(sjjhl >= tempHssl && isBuyDone == 0 && sjjhl != 0){isBuyDone = 1; break;}
            if(sjjhl > 0 && sjjhl < tempHssl ){isBuyDone = 1; break;}
            if(sjjhl >= tempHssl && sjjhl != 0){isBuyDone = 2;}
            if(sjjhl == 0){isBuyDone = 0;}
            detail.next();
          }
          detail.first();
          for(j=0;j<detail.getRowCount();j++){
            tempHssl = Double.parseDouble(detail.getValue("hssl").trim().length()>0?detail.getValue("hssl"):"0");
            sjrkl = Double.parseDouble(detail.getValue("sjrkl").trim().length()>0?detail.getValue("sjrkl"):"0");
            if(sjrkl == 0 && isStoreDone == 2){isStoreDone = 1; break;}
            if(sjrkl >= tempHssl && isStoreDone == 0 && sjrkl != 0){isStoreDone = 1; break;}
            if(sjrkl > 0 && sjrkl < tempHssl ){isStoreDone = 1; break;}
            if(sjrkl >= tempHssl && sjrkl != 0 ){isStoreDone = 2;}
            if(sjrkl == 0){isStoreDone = 0;}
            detail.next();
          }

          if(isStoreDone == 1){
            sb.append(" 已部分入库");
          }else if(isStoreDone == 2){
            sb.append("已全部入库");
          }else if(isBuyDone == 1){
            sb.append("已部分进货");
          }else if(isBuyDone == 2){
            sb.append("已全部进货");
          }

          list.setValue("ztms",sb.toString());
          sb.delete(0,sb.length());
        }
        String zsl = list.getValue("zsl");
        if(buyOrderBean.isDouble(zsl))
          t_zsl = t_zsl.add(new BigDecimal(zsl));
        String zje = list.getValue("zje");
        if(buyOrderBean.isDouble(zje))
          t_zje = t_zje.add(new BigDecimal(zje));
        boolean isInit = false;
        String rowClass =list.getValue("zt");
        if(rowClass.equals("0"))
          isInit = true;

        String czyid = list.getValue("czyid");
        //提交审批是否只有制单人可以提交
        //isApproveOnly = isApproveOnly && loginId.equals(zdrid);//如果时只有制单人才可以提交审批。制单人等于登录人才显示
        boolean isShow = isApproveOnly ? (loginId.equals(czyid) && isInit) : isInit;//如果时只有制单人才可以提交审批。制单人等于登录人才显示
        rowClass = engine.action.BaseAction.getStyleName(rowClass);

        String sprid = list.getValue("sprid");
        String htid = list.getValue("htid");
        boolean isCanCancle = buyOrderBean.isCanCancel(htid);//判断这个合同能否被完成如果合同被引用不显示完成按钮
        String zt=list.getValue("zt");
        //boolean isCancelApprove =  zt.equals("1");
        //isCancelApprove = isCancelApprove && loginId.equals(sprid);//是否可以取消合同
        boolean isCancelApprove=buyOrderBean.hasReferenced("VW_CG_CGHT","htid",list.getValue("htid"));//是否被进货单引用，如果被引用，则不能取消审批，否则，可以取消审批
        isCancelApprove=zt.equals("1") && loginId.equals(sprid)&&!isCancelApprove;
        boolean isComplete  = zt.equals("1") && !zt.equals("8") && loginBean.hasLimits(pageCode, op_over);//有强制完成的权限
        boolean isRepeal  = isCanCancle && !zt.equals("8") && !zt.equals("2") && !zt.equals("4") && loginBean.hasLimits(pageCode, op_cancel);//有废除合同的权限
    %>
    <tr id="tr_<%=list.getRow()%>" onDblClick="sumitForm(<%=Operate.EDIT%>,<%=list.getRow()%>)" onClick="showDetail(<%=list.getRow()%>)">
      <td <%=rowClass%> align="center" nowrap><input name="image2" class="img" type="image" title='<%=loginBean.hasLimits(pageCode, op_edit) ?"修改" :"查看"%>' onClick="sumitForm(<%=Operate.EDIT%>,<%=list.getRow()%>)" src="../images/edit.gif" border="0">
      <%if(isShow){%><input name="image3" class="img" type="image" title='提交审批'onClick="sumitForm(<%=Operate.ADD_APPROVE%>,<%=list.getRow()%>)" src="../images/approve.gif" border="0"><%}%>
      <%if(isCancelApprove){%><input name="image3" class="img" type="image" title='取消审批' onClick="if(confirm('是否取消审批该纪录？'))sumitForm(<%=buyOrderBean.CANCLE_APPROVE%>,<%=list.getRow()%>)" src="../images/clear.gif" border="0"><%}%>
      <%if(isComplete){%><input name="image5" class="img" type="image" title='完成' onClick="if(confirm('是否强制完成该纪录？'))sumitForm(<%=buyOrderBean.COMPLETE%>,<%=list.getRow()%>)" src="../images/ok.gif" border="0"><%}%>
      <%if(isRepeal){%><input name="image4" class="img" type="image" title='作废' onClick="if(confirm('是否确定作废该纪录？'))sumitForm(<%=buyOrderBean.REPEAL%>,<%=list.getRow()%>)" src="../images/close.gif" border="0"><%}%></td>
     <%table.printCells(pageContext, rowClass);%>
    </tr>
    <%  list.next();
      }
      i=count+1;
     %>
      <tr>
      <td class="tdTitle" nowrap>合计</td>
      <td class="td" nowrap>&nbsp;</td>
      <td class="td" nowrap></td>
      <td class="td" nowrap></td>
      <td class="td" nowrap></td>
      <td class="td" nowrap></td>
     <td class="td" nowrap></td>
      <td class="td" nowrap></td>
      <td class="td" nowrap></td>
      <td class="td" nowrap></td>
      <td align="right" class="td"><input type="text" class="ednone_r" style="width:100%" value='<%=t_zsl%>' readonly></td>
      <td align="right" class="td"><input type="text" class="ednone_r" style="width:100%" value='<%=t_zje%>' readonly></td>
      <td class="td" nowrap></td>
      <td class="td" nowrap></td>
      <td class="td" nowrap></td>
      <td class="td" nowrap></td>
      </tr>
      <%
      for(; i < iPage; i++){
        out.print("<tr>");
        table.printBlankCells(pageContext, "class=td");
        out.print("<td>&nbsp;</td></tr>");
      }
    %>
  </table>
</form>
<SCRIPT LANGUAGE="javascript">
initDefaultTableRow('tableview1',1);
<%if(!buyOrderBean.masterIsAdd()){
    int row = buyOrderBean.getSelectedRow();
    if(row >= 0)
      out.print("showSelected('tr_"+ row +"');");
  }%>
function sumitFixedQuery(oper)
{
  lockScreenToWait("处理中, 请稍候！");
  fixedQueryform.operate.value = oper;
  fixedQueryform.submit();
}
function showFixedQuery(){
  <%if(hasSearchLimit){%>showFrame('fixedQuery', true, "", true);<%}%>
}


function sumitSearchFrame(oper)
{
  lockScreenToWait("处理中, 请稍候！");
  searchform.operate.value = oper;
  searchform.submit();
}
function showSearchFrame(){
  hideFrame('fixedQuery');
  showFrame('searchframe', true, "", true);
}
function hide()
{
  hideFrame('fixedQuery');
}
function productCodeSelect(obj)
{
  ProdCodeChange(document.all['prod'], obj.form.name, 'srcVar=cpid&srcVar=cpbm&srcVar=product','fieldVar=cpid&fieldVar=cpbm&fieldVar=product', obj.value);
}
function productNameSelect(obj)
{
  ProdNameChange(document.all['prod'], obj.form.name, 'srcVar=cpid&srcVar=cpbm&srcVar=product','fieldVar=cpid&fieldVar=cpbm&fieldVar=product', obj.value);
}

function showInterFrame()
{
 // var url = "buy_order_edit2.jsp?operate="+oper+"&rownum="+rownum;oper, rownum  <%=Operate.ADD%>,-1
  var url = "buy_order_edit2.jsp?"
  document.all.interframe1.src = url;
  showFrame('detailDiv',true,"",true);
  }
  function hideFrameNoFresh(){
  hideFrame('detailDiv');
  }
  function hideInterFrame()//隐藏FRAME
  {
  hideFrame('detailDiv');
  form1.submit();
  }
</SCRIPT>
<%if(hasSearchLimit){%>
<form name="fixedQueryform" method="post" action="<%=curUrl%>" onsubmit="return false;" onKeyDown="return onInputKeyboard();">
  <INPUT TYPE="HIDDEN" NAME="operate" VALUE="">
  <div class="queryPop" id="fixedQuery" name="fixedQuery">
    <div class="queryTitleBox" align="right"><A onClick="hideFrame('fixedQuery')" href="#"><img src="../images/closewin.gif" border=0></A></div>
    <TABLE cellspacing=3 cellpadding=0 border=0>
      <TR>
        <TD> <TABLE cellspacing=3 cellpadding=0 border=0>
            <TR>
              <TD class="td" nowrap>合同编号</TD>
              <TD nowrap class="td"><INPUT class="edbox" style="WIDTH:130" id="htbh" name="htbh" value='<%=buyOrderBean.getFixedQueryValue("htbh")%>' onKeyDown="return getNextElement();"   ></TD>

               <%--
               <TD class="td" nowrap>业务员</TD>
               <TD nowrap class="td"><pc:select name="personid" addNull="1" style="width:130">
               <%=personBean.getList(buyOrderBean.getFixedQueryValue("personid"))%></pc:select>
               </TD>
               --%>
            </TR>
            <TR>
            <%
              String dwtxid = buyOrderBean.getFixedQueryValue("dwtxid");
              RowMap dwRow = corpBean.getLookupRow(dwtxid);%>
              <TD align="center" nowrap class="td">购货单位</TD>
              <td nowrap class="td" colspan=3>
              <input type="text" class="edbox" style="width:70" onKeyDown="return getNextElement();" name="dwdm" value='<%=dwRow.get("dwdm")%>' onchange="customerCodeSelect(this)" >
              <input type="text" name="dwmc"  style="width:260" value='<%=dwRow.get("dwmc")%>' class="edbox"  onchange="customerNameSelect(this)" >
              <INPUT TYPE="HIDDEN" NAME="dwtxid" value='<%=dwtxid%>'>
              <img style='cursor:hand' src='../images/view.gif' border=0 onClick="ProvideSingleSelect('fixedQueryform','srcVar=dwtxid&srcVar=dwmc&srcVar=dwdm','fieldVar=dwtxid&fieldVar=dwmc&fieldVar=dwdm',fixedQueryform.dwtxid.value)">
              <img style='cursor:hand' src='../images/delete.gif' BORDER=0 ONCLICK="dwtxid.value='';dwmc.value='';dwdm.value='';">
              </td>
            </TR>
            <TR>
              <TD nowrap class="td">合同日期</TD>
              <TD class="td" nowrap><INPUT class="edbox" style="WIDTH: 130px" name="htrq$a" value='<%=buyOrderBean.getFixedQueryValue("htrq$a")%>' maxlength='10' onChange="checkDate(this)" onKeyDown="return getNextElement();">
                <A href="#"><IMG title=选择日期 onClick="selectDate(htrq$a);" height=20 src="../images/seldate.gif" width=20 align=absMiddle border=0></A></TD>
              <TD class="td" nowrap align="center">--</TD>
              <TD class="td" nowrap><INPUT class="edbox" id="htrq$b" style="WIDTH: 130px" name="htrq$b" value='<%=buyOrderBean.getFixedQueryValue("htrq$b")%>' maxlength='10' onChange="checkDate(this)" onKeyDown="return getNextElement();">
                <A href="#"><IMG title=选择日期 onClick="selectDate(htrq$b);" height=20 src="../images/seldate.gif" width=20 align=absMiddle border=0></A></TD>
            </TR>

            <TR>
              <TD nowrap class="td">有效期始</TD>
              <TD nowrap class="td"><INPUT class="edbox" style="WIDTH: 130px" name="ksrq$a" value='<%=buyOrderBean.getFixedQueryValue("ksrq$a")%>' maxlength='10' onChange="checkDate(this)" onKeyDown="return getNextElement();">
                <A href="#"><IMG title=选择日期 onClick="selectDate(ksrq$a);" height=20 src="../images/seldate.gif" width=20 align=absMiddle border=0></A></TD>
              <TD align="center" nowrap class="td">--</TD>
              <TD class="td" nowrap><INPUT class="edbox" style="WIDTH: 130px" name="ksrq$b" value='<%=buyOrderBean.getFixedQueryValue("ksrq$b")%>' maxlength='10' onChange="checkDate(this)" onKeyDown="return getNextElement();">
                <A href="#"><IMG title=选择日期 onClick="selectDate(ksrq$b);" height=20 src="../images/seldate.gif" width=20 align=absMiddle border=0></A></TD>
            </TR>
            <TR>
              <TD nowrap class="td">有效期止</TD>
              <TD nowrap class="td"><INPUT class="edbox" style="WIDTH: 130px" name="jsrq$a" value='<%=buyOrderBean.getFixedQueryValue("jsrq$a")%>' maxlength='10' onChange="checkDate(this)" onKeyDown="return getNextElement();">
                <A href="#"><IMG title=选择日期 onClick="selectDate(jsrq$a);" height=20 src="../images/seldate.gif" width=20 align=absMiddle border=0></A></TD>
              <TD align="center" nowrap class="td">--</TD>
              <TD class="td" nowrap><INPUT class="edbox" style="WIDTH: 130px" name="jsrq$b" value='<%=buyOrderBean.getFixedQueryValue("jsrq$b")%>' maxlength='10' onChange="checkDate(this)" onKeyDown="return getNextElement();">
                <A href="#"><IMG title=选择日期 onClick="selectDate(jsrq$b);" height=20 src="../images/seldate.gif" width=20 align=absMiddle border=0></A></TD>
            </TR>
            <TR>
              <TD nowrap class="td">签定地点</TD>
              <TD nowrap class="td"><INPUT class="edbox" style="WIDTH:130" id="qddd" name="qddd" value='<%=buyOrderBean.getFixedQueryValue("qddd")%>' onKeyDown="return getNextElement();"></TD>
              <TD class="td" nowrap>部门</TD>
              <TD nowrap class="td"><pc:select name="deptid" addNull="1" style="width:130">
         <%=deptBean.getList(buyOrderBean.getFixedQueryValue("deptid"))%></pc:select>
           </TD>
             </TR>
                        <tr>
            <td noWrap  class="td">客户类型</td>
            <td width="120" class="td">
            <%String khlx = buyOrderBean.getFixedQueryValue("khlx");%>
            <pc:select name="khlx" style="width:160" addNull="1" value="<%=khlx%>" >
              <pc:option value="A">A</pc:option> <pc:option value="C">C</pc:option>
            </pc:select>
            </td>
              <TD class="td" nowrap>
                <pc:select name="personid" addNull="1" style="width:100">
                  <%=personBean.getList(buyOrderBean.getFixedQueryValue("personid"))%>
                </pc:select>
               </TD>
            </tr>
            <TR>

               <TD align="center" nowrap class="td">原辅料名称</TD>
               <td nowrap class="td" colspan="3">
                <input class="EDBox" style="WIDTH:70px" name="cpbm" value='<%=buyOrderBean.getFixedQueryValue("cpbm")%>'onchange="productCodeSelect(this)" onKeyDown="return getNextElement();" >
                <input class="EDBox" style="WIDTH:260px" name="product" value='<%=buyOrderBean.getFixedQueryValue("product")%>'  onchange="productNameSelect(this)"  onKeyDown="return getNextElement();">
                <INPUT TYPE="hidden" NAME="cpid" value="<%=buyOrderBean.getFixedQueryValue("cpid")%>">
                <img style='cursor:hand' src='../images/view.gif' border=0 onClick="ProdSingleSelect('fixedQueryform','srcVar=cpid&srcVar=product&srcVar=cpbm','fieldVar=cpid&fieldVar=product&fieldVar=cpbm',fixedQueryform.cpid.value)">
                <img style='cursor:hand' src='../images/delete.gif' BORDER=0 ONCLICK="cpid.value='';product.value='';cpbm.value=''">
            </td>
            </TR>
              <TD nowrap class="td">品名模糊</TD>
              <TD nowrap class="td"><INPUT class="edbox" style="WIDTH: 130px" name="pm" value='<%=buyOrderBean.getFixedQueryValue("pm")%>'   onKeyDown="return getNextElement();">
               </TD>
              <TD align="center" nowrap class="td">规格模糊</TD>
              <TD class="td" nowrap><INPUT class="edbox" style="WIDTH: 130px" name="gg" value='<%=buyOrderBean.getFixedQueryValue("gg")%>'  onKeyDown="return getNextElement();">
                </TD>
            </TR>
            <TR>
              <%--
              <TD class="td" nowrap>产品编码</TD>
              <TD class="td" nowrap><INPUT class="edbox" style="WIDTH:130" id="htid$cpbm" name="htid$cpbm" value='<%=buyOrderBean.getFixedQueryValue("htid$cpbm")%>' onKeyDown="return getNextElement();"></TD>
              --%>
              <TD class="td" nowrap>规格属性</TD>
              <TD class="td" nowrap><INPUT class="edbox" style="WIDTH:130" id="sxz" name="sxz" value='<%=buyOrderBean.getFixedQueryValue("sxz")%>' onKeyDown="return getNextElement();"></TD>
            </TR>
            <TR>
              <TD class="td" nowrap>状态</TD>
              <TD colspan="3" nowrap class="td">
                <%String zt = buyOrderBean.getFixedQueryValue("zt");%>
                <input type="radio" name="zt" value=""<%=zt.equals("")?" checked" :""%>>
                全部
                <input type="radio" name="zt" value="9"<%=zt.equals("9")?" checked" :""%>>
                审批中
                <input type="radio" name="zt" value="0"<%=zt.equals("0")?" checked" :""%>>
                未审
                <input type="radio" name="zt" value="1"<%=zt.equals("1")?" checked" :""%>>
                已审
                <input type="radio" name="zt" value="2"<%=zt.equals("2")?" checked" :""%>>
                已入库
                <input type="radio" name="zt" value="8"<%=zt.equals("8")?" checked" :""%>>
                已完成
                <input type="radio" name="zt" value="4"<%=zt.equals("4")?" checked" :""%>>
                已作废
                </TD>
            </TR>
            <TR>
              <TD nowrap colspan=5 height=30 align="center"><INPUT class="button" onClick="sumitFixedQuery(<%=Operate.FIXED_SEARCH%>)" type="button" value=" 查询(F)" name="button" onKeyDown="return getNextElement();">
                <pc:shortcut key="f" script='<%="sumitFixedQuery("+ Operate.FIXED_SEARCH +",-1)"%>'/>
                <INPUT class="button" onClick="hideFrame('fixedQuery')" type="button" value=" 关闭(X)" name="button2" onKeyDown="return getNextElement();">
                <pc:shortcut key="x" script='hide();'/>
              </TD>
            </TR>
          </TABLE></TD>
      </TR>
    </TABLE>
  </DIV>




  <div class="queryPop" id="detailDiv" name="detailDiv">
  <div class="queryTitleBox" align="right"><A onClick="hideFrame('detailDiv')" href="#"><img src="../images/closewin.gif" border=0></A></div>
  <TABLE cellspacing=0 cellpadding=0 border=0>
    <TR>
      <TD><iframe id="interframe1" src="" width="750" height="260" marginWidth="0" marginHeight="0" frameBorder="0" noResize scrolling="no"></iframe>
      </TD>
    </TR>
  </TABLE>
</div>
</form>
<%} out.print(retu);%>
</body>
</html>