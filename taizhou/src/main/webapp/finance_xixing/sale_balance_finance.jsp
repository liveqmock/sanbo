<%--
销售结算
2004-2-16增加了单位名称的模糊输入
--%>
<%@ page contentType="text/html; charset=UTF-8" %><%@ include file="../pub/init.jsp"%>
<%@ page import="engine.dataset.*,engine.project.Operate,java.math.BigDecimal,engine.html.*,java.util.ArrayList,engine.erp.finance.*"%><%!
  String op_add    = "op_add";
  String op_delete = "op_delete";
  String op_edit   = "op_edit";
  String op_search = "op_search";
  String op_approve ="op_approve";
  String pageCode = "sale_balance";
%>
<%
if(!loginBean.hasLimits(pageCode, request, response))
    return;
  engine.erp.finance.xixing.B_SaleBalance b_SaleBalanceBean  =  engine.erp.finance.xixing.B_SaleBalance.getInstance(request);

  engine.project.LookUp balanceModeBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_BALANCE_MODE);
  engine.project.LookUp corpBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_CORP);
  engine.project.LookUp deptBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_DEPT);
  engine.project.LookUp personBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_PERSON);
  engine.project.LookUp bankaccountBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_BANK_ACCOUNT);
  engine.project.LookUp bankBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_BANK);
  //engine.project.LookUp khyeBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_CUST_ACCOUNT_RECEIVABLE);//通过提单取余额
  engine.project.LookUp khyeBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_CUST_ACCOUNT_CKDRECEIVE);//通过出库单取余额
%>
<html>
<head>
<title></title>
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../scripts/public.css" type="text/css">
</head>
<script language="javascript" src="../scripts/validate.js"></script>
<script language="javascript" src="../scripts/rowcontrol.js"></script>
<script language="javascript" src="../scripts/tabcontrol.js"></script>
<script language="javascript">
function sumitForm(oper, row)
{
  lockScreenToWait("处理中, 请稍候！");
  form1.rownum.value = row;
  form1.operate.value = oper;
  form1.submit();
}
function backList()
{
  location.href='sale_balance.jsp';
}
//客户代码
function customerCodeSelect(obj)
{
    CustCodeChange(document.all['prod'], obj.form.name,'srcVar=dwdm&srcVar=dwtxid&srcVar=dwmc','fieldVar=dwdm&fieldVar=dwtxid&fieldVar=dwmc',obj.value,'sumitForm(<%=b_SaleBalanceBean.DWTXID_CHANGE%>,-1)');
}
//客户名称
function customerNameChange(obj)
{
    CustomerNameChange('2',document.all['prod'], obj.form.name,'srcVar=dwdm&srcVar=dwtxid&srcVar=dwmc','fieldVar=dwdm&fieldVar=dwtxid&fieldVar=dwmc',obj.value,'sumitForm(<%=b_SaleBalanceBean.DWTXID_CHANGE%>,-1)');
}
function deptchange(){
   associateSelect(document.all['prod'], '<%=engine.project.SysConstant.BEAN_PERSON%>', 'personid', 'deptid', eval('form1.deptid.value'), '');
}
function yhchange(){
   associateSelect(document.all['prod'], '<%=engine.project.SysConstant.BEAN_BANK_ACCOUNT%>', 'zh', 'yhmc', eval('form1.yh.value'), '');
}
</script>
<%
  String retu = b_SaleBalanceBean.doService(request, response);
  if(retu.indexOf("backList();")>-1)
  {
    out.print(retu);
    return;
  }
  String curUrl = request.getRequestURL().toString();
  EngineDataSet ds = b_SaleBalanceBean.getMaterTable();
  EngineDataSet list = b_SaleBalanceBean.getDetailTable();//引用过来的数据集
  HtmlTableProducer masterProducer = b_SaleBalanceBean.masterProducer;
  HtmlTableProducer detailProducer = b_SaleBalanceBean.detailProducer;
  RowMap masterRow = b_SaleBalanceBean.getMasterRowinfo();//主表一行
  RowMap[] detailRows= b_SaleBalanceBean.getDetailRowinfos();//从表多行
  ds.first();
  String zt=masterRow.get("zt");
  if(b_SaleBalanceBean.isApprove)
  {
    corpBean.regData(ds, "dwtxid");
    personBean.regData(ds, "personid");

  }
  //khyeBean.regData(ds, new String[]{"fgsid","dwtxid"});
  String djxz=masterRow.get("djxz");
  boolean isEnd =  b_SaleBalanceBean.isApprove || (!b_SaleBalanceBean.masterIsAdd() && !zt.equals("0"));
  //没有结束,在修改状态,并有删除权限
  boolean isCanDelete = !isEnd && !b_SaleBalanceBean.masterIsAdd() && loginBean.hasLimits(pageCode, op_delete);
  isEnd = isEnd || !(b_SaleBalanceBean.masterIsAdd() ? loginBean.hasLimits(pageCode, op_add) : loginBean.hasLimits(pageCode, op_edit));
  FieldInfo[] mBakFields = masterProducer.getBakFieldCodes();//主表用户的自定义字段
  String edClass = isEnd ? "class=edline" : "class=edbox";
  String detailClass = isEnd ? "class=ednone" : "class=edFocused";
  String detailClass_r = isEnd ? "class=ednone_r" : "class=edFocused_r";
  String readonly = isEnd ? " readonly" : "";
  String title = zt.equals("0") ? ("未审核") : ("已审核");
  boolean count=list.getRowCount()==0?true:false;
  RowMap corpRow =corpBean.getLookupRow(masterRow.get("dwtxid"));
 // RowMap khyeRow = khyeBean.getLookupRow(new String[] {masterRow.get("fgsid"),masterRow.get("dwtxid")});
 // String khye = khyeBean.getLookupName(new String[] {masterRow.get("fgsid"),masterRow.get("dwtxid")});
  bankaccountBean.regConditionData("yhmc", new String[]{});
  bankBean.regData(ds, "yh");
%>
<BODY oncontextmenu="window.event.returnValue=true" >
<iframe id="prod" src="" width="95%" height=25 marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=no style="display:none"></iframe>
<form name="form1" action="<%=curUrl%>" method="POST" onsubmit="return false;" onKeyDown="return onInputKeyboard();" >
  <table WIDTH="100%" BORDER=0 CELLSPACING=0 CELLPADDING=0><tr>
    <td align="center" height="5"></td>
  </tr></table>
  <INPUT TYPE="HIDDEN" NAME="operate" value="">
  <INPUT TYPE="HIDDEN" NAME="rownum" value="">
  <table BORDER="0" CELLPADDING="1" CELLSPACING="0" align="center" width="760">
    <tr valign="top">
      <td><table border=0 CELLSPACING=0 CELLPADDING=0 class="table">
        <tr>
            <td class="activeVTab">销售结算(<%=title%>)</td>
          </tr>
        </table>
        <table class="editformbox" CELLSPACING=1 CELLPADDING=0 >
          <tr>
            <td>
              <table CELLSPACING="1" CELLPADDING="1" BORDER="0" bgcolor="#f0f0f0" width="100%">
                <%
                  corpBean.regData(ds,"dwtxid");
                  personBean.regConditionData(ds,"deptid");

                 %>
                  <tr>
                  <td  noWrap class="tdTitle"><%=masterProducer.getFieldInfo("rq").getFieldname()%></td>
                  <td  noWrap class="td"><input type="text" name="rq" value='<%=masterRow.get("rq")%>' maxlength='10' style="width:110" <%=edClass%> onChange="checkDate(this)" onKeyDown="return getNextElement();" >
                  <%if(!isEnd){%><a href="#"><img align="absmiddle" src="../images/seldate.gif" width="20" height="16" border="0" title="选择日期" onclick="selectDate(form1.rq);"></a>
                  <%}%></td>
                  <td  noWrap class="tdTitle"><%=masterProducer.getFieldInfo("djh").getFieldname()%></td>
                  <td  noWrap class="td"><input type="text" name="djh" value='<%=masterRow.get("djh")%>' maxlength='<%=ds.getColumn("djh").getPrecision()%>' style="width:110" class="edline" onKeyDown="return getNextElement();" readonly></td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("djxz").getFieldname()%></td>
                  <td noWrap class="td">
                  <%if(!isEnd){%>
                  <INPUT TYPE="radio" NAME="djxz" VALUE="1" <%=(masterRow.get("djxz").equals("1"))?"checked":((masterRow.get("djxz").equals(""))?"checked":"")%>>销售收款
                  <INPUT TYPE="radio" NAME="djxz" VALUE="-1" <%=(masterRow.get("djxz").equals("-1"))?"checked":""%>>销售退款
                  <%}else{%><%=(masterRow.get("djxz").equals("1"))?"销售收款":"销售退款"%><%}%>
                  </td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("deptid").getFieldname()%></td>
                  <td noWrap class="td">
                    <%
                      String t="sumitForm("+b_SaleBalanceBean.DEPT_CHANGE+",-1)";
                      if(isEnd) out.print("<input type='text' value='"+deptBean.getLookupName(masterRow.get("deptid"))+"' style='width:110' class='edline' readonly >");
                    else {
                     %>
                    <pc:select name="deptid" addNull="1" style="width:110" >
                      <%=deptBean.getList(masterRow.get("deptid"))%> </pc:select>
                    <%}%></td>
                 </tr>
                 <tr>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("dwtxid").getFieldname()%></td><%--购货单位--%>
                  <td  noWrap colspan='3' class="td">
                    <input type="hidden" name="dwtxid" value='<%=masterRow.get("dwtxid")%>'>
                    <input type="text" <%=detailClass%> style="width:70" onKeyDown="return getNextElement();" name="dwdm" value='<%=corpRow.get("dwdm")%>' onChange="customerCodeSelect(this)" <%=readonly%>>
                    <input type="text" <%=detailClass%> name="dwmc" value='<%=corpBean.getLookupName(masterRow.get("dwtxid"))%>'  onKeyDown="return getNextElement();"  style="width:200"  onchange="customerNameChange(this)" <%=readonly%>>
                    <%if(!isEnd){%>
                    <img style='cursor:hand' src='../images/view.gif' border=0 onClick="CustSingleSelect('form1','srcVar=dwtxid&srcVar=dwmc','fieldVar=dwtxid&fieldVar=dwmc',form1.dwtxid.value,'sumitForm(<%=b_SaleBalanceBean.DWTXID_CHANGE%>,-1)');">
                    <%}%>
                  </td>

                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("jsdh").getFieldname()%></td>
                  <td noWrap class="td"><input type="text" name="jsdh" value='<%=masterRow.get("jsdh")%>' maxlength='<%=ds.getColumn("jsdh").getPrecision()%>' style="width:110" <%=detailClass_r%> onKeyDown="return getNextElement();"<%=readonly%>></td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("je").getFieldname()%></td>
                  <td noWrap class="td"><input type="text" name="je" value='<%=masterRow.get("je")%>' maxlength='<%=ds.getColumn("je").getPrecision()%>' style="width:110" <%=detailClass_r%> onKeyDown="return getNextElement();" <%=readonly%>></td>
                 </tr>
                 <tr>
                  <td noWrap class="tdTitle"><%="客户类型"%></td>
                  <td width="120" class="td">
                  <%String khlx = masterRow.get("khlx");if(isEnd){out.print(khlx.equals("A")?"A":"C");}else{%>
                  <pc:select name="khlx" style="width:110" value="<%=khlx%>">
                    <pc:option value=""></pc:option><pc:option value="A">A</pc:option> <pc:option value="C">C</pc:option>
                  </pc:select>
                  <%}%>
                </td>
                  <td  noWrap class="tdTitle"><%=masterProducer.getFieldInfo("jsfsid").getFieldname()%></td>
                  <td  noWrap class="td">
                  <%if(isEnd){String jsfsid=masterRow.get("jsfsid");out.print("<input type='text' value='"+balanceModeBean.getLookupName(masterRow.get("jsfsid"))+"' style='width:180' class='edline' readonly>");
                    }else {%>
                    <pc:select name="jsfsid" addNull="1" style="width:110">
                    <%=balanceModeBean.getList(masterRow.get("jsfsid"))%>
                    </pc:select>
                 <%}%></td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("bz").getFieldname()%></td>
                  <td  class="td" colspan="3"><input type="text" align="left" <%=edClass%> name="bz" value='<%=masterRow.get("bz")%>' maxlength='<%=ds.getColumn("bz").getPrecision()%>' style="width:100%"  onKeyDown="return getNextElement();"<%=readonly%>></td>
                </tr>
                <tr>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("yh").getFieldname()%></td>
                  <td noWrap class="td" >
                  <%if(isEnd)
                    {
                    out.print("<input type='text' value='"+masterRow.get("yh")+"' style='width:110' class='edline' readonly>");
                    }else
                    {String yh=masterRow.get("yh");%>
                  <pc:select name="yh" addNull="1" style="width:180"   onSelect="yhchange()"  combox="1" value="<%=yh%>">
                  <%=bankBean.getList()%> </pc:select>
                   <%}%></td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("zh").getFieldname()%></td>
                  <td noWrap class="td" >
                  <%if(isEnd) out.print("<input type='text' value='"+masterRow.get("zh")+"' style='width:110' class='edline' readonly>");
                  else {String zh=masterRow.get("zh");%>
                  <pc:select name="zh" addNull="1" style="width:180" combox="1" value="<%=zh%>">
                  <%=bankaccountBean.getList(masterRow.get("zh"),"yhmc",masterRow.get("yh"))%> </pc:select>
                   <%}%></td>
                 <%--
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("personid").getFieldname()%></td>
                  <td   noWrap class="td">
                  <%if(isEnd) out.print("<input type='text' value='"+personBean.getLookupName(masterRow.get("personid"))+"' style='width:110' class='edline' readonly>");
                  else {%>
                  <pc:select name="personid" addNull="1" style="width:110">
                    <%=personBean.getList(masterRow.get("personid"),"deptid",masterRow.get("deptid"))%> </pc:select>
                   <%}%></td>--%>

		<%--   <td noWrap class="tdTitle">当前余额</td>
		   <td noWrap class="td"><input type="text"  class=edline name="khye" value='<%=khye%>'  onKeyDown="return getNextElement();"  style="width:100"  readonly>
                  </td>--%>
                 </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>
        <table CELLSPACING=0 CELLPADDING=0 width="100%" align="center">
          <tr>
            <td class="td"><b>登记日期:</b><%=masterRow.get("czrq")%>
              <input type="text" class='ednone_r'  style="width:30" onKeyDown="return getNextElement();"   value='' maxlength='' readonly></td>
            <td class="td"></td>
            <td class="td" align="right"><b>制单人:</b><%=masterRow.get("czy")%></td>
          </tr>
          <tr>
            <td colspan="3" noWrap class="tableTitle">
              <%if(!isEnd){
               String we= "sumitForm("+Operate.POST_CONTINUE+");";
               String po = "sumitForm("+Operate.POST+");";
              %>
              <input name="button2" type="button" class="button" onClick="sumitForm(<%=Operate.POST_CONTINUE%>);" value="保存继续(N)">
              <pc:shortcut key="n" script="<%=we%>" />
              <input name="btnback" type="button" class="button" onClick="sumitForm(<%=Operate.POST%>);" value="保存返回(S)">
              <pc:shortcut key="s" script="<%=po%>" />
            <%}%>
              <%if(isCanDelete){
                String del = "if(confirm('是否删除该记录？'))sumitForm("+Operate.DEL+");";
             %>
              <input name="button3" type="button" class="button" onClick="if(confirm('是否删除该记录？'))sumitForm(<%=Operate.DEL%>);" value="删除(D)">
              <pc:shortcut key="d" script="<%=del%>" />
              <%}%>
              <%--input name="button4" type="button" class="button" onClick="sumitForm(<%=Operate.MASTER_CLEAR%>);" value=" 打印 "--%>
              <input name="btnback" type="button" class="button" onClick="backList();" value="返回(C)">
              <pc:shortcut key="c" script="backList();" />
            </td>
          </tr>
        </table></td>
    </tr>
  </table>
</form>
<script language="javascript">
  function formatQty(srcStr){ return formatNumber(srcStr, '<%=loginBean.getQtyFormat()%>');}
  function formatPrice(srcStr){ return formatNumber(srcStr, '<%=loginBean.getPriceFormat()%>');}
  function formatSum(srcStr){ return formatNumber(srcStr, '<%=loginBean.getSumFormat()%>');}
  function sl_onchange(i, isBigUnit)
  {
    var jsjeObj = document.all['jsje_'+i];
    var tclObj = document.all['tcl_'+i];
    var tcjObj = document.all['tcj_'+i];
    if(jsjeObj.value=="")
      return;
    if(isNaN(jsjeObj.value)){
      alert("输入的数量非法");
      jsjeObj.focus();
      return;
    }
    tcjObj.value=formatQty(parseFloat(jsjeObj.value) * parseFloat(tclObj.value))*0.01;
    cal_tot('jsje');
    cal_tot('tcj');
  }
  function cal_tot(type)
  {
    var tmpObj;
    var tot=0;
    for(i=0; i<<%=detailRows.length%>; i++)
      {
      if(type == 'jsje')
        tmpObj = document.all['jsje_'+i];
      else if(type == 'tcj')
        tmpObj = document.all['tcj_'+i];
      else
        return;
      if(tmpObj.value!="" && !isNaN(tmpObj.value))
        tot += parseFloat(tmpObj.value);
    }
    if(type == 'jsje')
    {
      document.all['t_jsje'].value = formatQty(tot);
      //document.all['je'].value = formatQty(tot);
    }
      <%if(djxz.equals("1")){%>
        else if(type == 'tcj')
          document.all['t_tcj'].value = formatQty(tot);
      <%}%>
        }
  function TdhwMultiSelect(frmName,srcVar,fieldVar,curID,methodName,notin)
  {
    var winopt = "location=no scrollbars=yes menubar=no status=no resizable=1 width=640 height=450  top=0 left=0";
    var winName= "MultiProdSelector";
    paraStr = "../finance/sale_balance_import_lading_product.jsp?operate=0&multi=1&srcFrm="+frmName+"&"+srcVar+"&"+fieldVar+"&dwtxid="+curID;
    if(methodName+'' != 'undefined')
      paraStr += "&method="+methodName;
    if(notin+'' != 'undefined')
      paraStr += "&notin="+notin;
    newWin =window.open(paraStr,winName,winopt);
    newWin.focus();
  }
/*
  function selctTDHWOfLading()
  {
    if(form1.dwtxid.value=='')
    {
      alert('请选择购货单位');
      return;
    }
    TdhwMultiSelect('form1','srcVar=tdhwids','fieldVar=tdid',form1.dwtxid.value,"sumitForm(<%=b_SaleBalanceBean.DETAIL_SALE_ADD%>,-1)");
    }
*/
  function ViewCust()
  {
    if(form1.dwtxid.value=="")
    {
      alert('请选择单位!');
      return;
    }
    paraStr = "../baseinfo/corpedit.jsp?operate=<%=Operate.BROWS%>&dwtxid="+form1.dwtxid.value;
    openSelectUrl(paraStr, "BrowserCust", winopt2);
  }
  function OrderSingleSelect(frmName,srcVar,fieldVar,curID,methodName,notin)
  {
    var winopt = "location=no scrollbars=yes menubar=no status=no resizable=1 width=640 height=450  top=0 left=0";
    var winName= "SingleladingSelector";
    paraStr = "../finance/sale_balance_import_lading.jsp?operate=0&srcFrm="+frmName+"&"+srcVar+"&"+fieldVar+"&dwtxid="+curID;
    if(methodName+'' != 'undefined')
      paraStr += "&method="+methodName;
    if(notin+'' != 'undefined')
      paraStr += "&notin="+notin;
    newWin =window.open(paraStr,winName,winopt);
    newWin.focus();
  }
  function selctbilloflading()
  {
    form1.selectedtdid.value='';
    OrderSingleSelect('form1','srcVar=selectedtdid','fieldVar=tdid',form1.dwtxid.value,"sumitForm(<%=b_SaleBalanceBean.IMPORT_TD%>,-1)");
  }
</script>
</script>
<%
//&#$
if(b_SaleBalanceBean.isApprove){%><jsp:include page="../pub/approve.jsp" flush="true"/><%}%>
<%out.print(retu);%>

</BODY>
</Html>