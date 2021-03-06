<%--
进口结算
2004-2-16增加了单位名称的模糊输入
--%>
<%@ page contentType="text/html; charset=UTF-8" %><%@ include file="../pub/init.jsp"%>
<%@ page import="engine.dataset.*,engine.project.Operate,java.math.BigDecimal,engine.html.*,java.util.ArrayList,engine.erp.income.In_BuyBalance"%><%!
  String op_add    = "op_add";
  String op_delete = "op_delete";
  String op_edit   = "op_edit";
  String op_search = "op_search";
  String op_approve ="op_approve";
  String pageCode = "income_balance";
%>
<%
if(!loginBean.hasLimits(pageCode, request, response))
    return;
  In_BuyBalance In_BuyBalanceBean  =  In_BuyBalance.getInstance(request);

  engine.project.LookUp balanceModeBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_BALANCE_MODE);
  engine.project.LookUp corpBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_CORP);
  engine.project.LookUp deptBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_DEPT);
  engine.project.LookUp personBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_PERSON);
  engine.project.LookUp bankaccountBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_BANK_ACCOUNT);
  engine.project.LookUp bankBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_BANK);
  engine.project.LookUp wbBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_FOREIGN_CURRENCY);
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
  location.href='income_balance.jsp';
}
//客户代码
function customerCodeSelect(obj)
{
    CustomerCodeChange('1',document.all['prod'], obj.form.name,'srcVar=dwdm&srcVar=dwtxid&srcVar=dwmc&srcVar=dfyh&srcVar=dfzh','fieldVar=dwdm&fieldVar=dwtxid&fieldVar=dwmc&fieldVar=khh&fieldVar=zh',obj.value,'sumitForm(<%=In_BuyBalanceBean.DWTXID_CHANGE%>,-1)');
}
//客户名称
function customerNameChange(obj)
{
    CustomerNameChange('1',document.all['prod'], obj.form.name,'srcVar=dwdm&srcVar=dwtxid&srcVar=dwmc&srcVar=dfyh&srcVar=dfzh','fieldVar=dwdm&fieldVar=dwtxid&fieldVar=dwmc&fieldVar=khh&fieldVar=zh',obj.value,'sumitForm(<%=In_BuyBalanceBean.DWTXID_CHANGE%>,-1)');
}
function deptchange(){
   associateSelect(document.all['prod'], '<%=engine.project.SysConstant.BEAN_PERSON%>', 'personid', 'deptid', eval('form1.deptid.value'), '');
}
function yhchange(){
   associateSelect(document.all['prod'], '<%=engine.project.SysConstant.BEAN_BANK_ACCOUNT%>', 'zh', 'yhmc', eval('form1.yh.value'), '');
}
</script>
<%
  String retu = In_BuyBalanceBean.doService(request, response);
  if(retu.indexOf("backList();")>-1)
  {
    out.print(retu);
    return;
  }
  String curUrl = request.getRequestURL().toString();
  EngineDataSet ds = In_BuyBalanceBean.getMaterTable();
  EngineDataSet list = In_BuyBalanceBean.getDetailTable();//引用过来的数据集
  HtmlTableProducer masterProducer = In_BuyBalanceBean.masterProducer;
  HtmlTableProducer detailProducer = In_BuyBalanceBean.detailProducer;
  RowMap masterRow = In_BuyBalanceBean.getMasterRowinfo();//主表一行
  RowMap[] detailRows= In_BuyBalanceBean.getDetailRowinfos();//从表多行
  ds.first();
  String zt=masterRow.get("zt");
  if(In_BuyBalanceBean.isApprove)
  {
    corpBean.regData(ds, "dwtxid");
    personBean.regData(ds, "personid");
  }
  String djxz=masterRow.get("djxz");
  boolean isEnd =  In_BuyBalanceBean.isApprove || (!In_BuyBalanceBean.masterIsAdd() && !zt.equals("0"));
  //没有结束,在修改状态,并有删除权限
  boolean isCanDelete = !isEnd && !In_BuyBalanceBean.masterIsAdd() && loginBean.hasLimits(pageCode, op_delete);
  isEnd = isEnd || !(In_BuyBalanceBean.masterIsAdd() ? loginBean.hasLimits(pageCode, op_add) : loginBean.hasLimits(pageCode, op_edit));
  FieldInfo[] mBakFields = masterProducer.getBakFieldCodes();//主表用户的自定义字段
  String edClass = isEnd ? "class=edline" : "class=edFocused";
  String detailClass = edClass;//isEnd ? "class=edline" : "class=edFocused";
  String detailClass_r = isEnd ? "class=ednone_r" : "class=edFocused_r";
  String readonly = isEnd ? " readonly" : "";
  String title = zt.equals("0") ? ("未审核") : ("已审核");
  String tdlx=djxz.equals("2")?"企业普通发票":"增值税发票";
  boolean count=list.getRowCount()==0?true:false;
  //String yh
  RowMap corpRow =corpBean.getLookupRow(masterRow.get("dwtxid"));
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
            <td class="activeVTab">进口结算(<%=title%>)</td>
          </tr>
        </table>
        <table class="editformbox" CELLSPACING=1 CELLPADDING=0 >
          <tr>
            <td>
              <table CELLSPACING="1" CELLPADDING="1" BORDER="0" bgcolor="#f0f0f0" width="100%">
                <%
                  corpBean.regData(ds,"dwtxid");
                  personBean.regConditionData(ds,"deptid");
                  wbBean.regConditionData(ds,"wbid");
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
                  <INPUT TYPE="radio" NAME="djxz" VALUE="2" <%=(masterRow.get("djxz").equals("2"))?"checked":((masterRow.get("djxz").equals(""))?"checked":"")%>>采购付款
                  <INPUT TYPE="radio" NAME="djxz" VALUE="-2" <%=(masterRow.get("djxz").equals("-2"))?"checked":""%>>采购退款
                  <%}else{%><%=(masterRow.get("djxz").equals("2"))?"进口付款":"进口退款"%><%}%></td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("deptid").getFieldname()%></td>
                  <td noWrap class="td">
                    <%
                      String t="sumitForm("+In_BuyBalanceBean.DEPT_CHANGE+",-1)";
                      if(isEnd) out.print("<input type='text' value='"+deptBean.getLookupName(masterRow.get("deptid"))+"' style='width:110' class='edline' readonly >");
                    else {
                     %>
                    <pc:select name="deptid" addNull="1" style="width:110" onSelect="deptchange();">
                      <%=deptBean.getList(masterRow.get("deptid"))%> </pc:select>
                    <%}%></td>
                 </tr>
                 <tr>
                  <td noWrap class="tdTitle">供货商</td><%--购货单位--%>
                  <td  noWrap colspan='3' class="td">
                    <input type="hidden" name="dwtxid" value='<%=masterRow.get("dwtxid")%>'>
                    <input type="text" <%=edClass%> style="width:70" onKeyDown="return getNextElement();" name="dwdm" value='<%=corpRow.get("dwdm")%>' onchange="customerCodeSelect(this)" <%=readonly%>>
                    <input type="text" <%=edClass%> name="dwmc" value='<%=corpBean.getLookupName(masterRow.get("dwtxid"))%>'  onKeyDown="return getNextElement();"  style="width:200"  onchange="customerNameChange(this)" <%=readonly%>>
                    <%if(!isEnd){%>
                    <img style='cursor:hand' src='../images/view.gif' border=0 onClick="ProvideSingleSelect('form1','srcVar=dwtxid&srcVar=dwmc&srcVar=dfyh&srcVar=dfzh','fieldVar=dwtxid&fieldVar=dwmc&fieldVar=khh&fieldVar=zh',form1.dwtxid.value,'sumitForm(<%=In_BuyBalanceBean.DWTXID_CHANGE%>,-1)');">
                    <%}%>
                    <%--<img style='cursor:hand' src='../images/dept.gif' border=0 onClick="ViewCust();">--%>
                  </td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("jsdh").getFieldname()%></td>
                  <td noWrap class="td"><input type="text" name="jsdh" value='<%=masterRow.get("jsdh")%>' maxlength='<%=ds.getColumn("jsdh").getPrecision()%>' style="width:110" <%=edClass%> onKeyDown="return getNextElement();"<%=readonly%>></td>
                  <td noWrap class="tdTitle">外币类别</td>
                  <td noWrap class="td">
                  <%String sumit = "if(form1.wbid.value!='"+masterRow.get("wbid")+"')sumitForm("+In_BuyBalanceBean.WB_ONCHANGE+")";%>
                  <% if(isEnd) out.print("<input name='wbid' type='text' value='"+wbBean.getLookupName(masterRow.get("wbid"))+"'style='width:110' class='edline' readonly>");
                  else{%>
                  <pc:select name="wbid" style="width:110" addNull="1" onSelect="<%=sumit%>">
                  <%=wbBean.getList(masterRow.get("wbid"))%>
                  </pc:select>
                 <%}%>
                  </td>
                 </tr>
                 <tr>
                  <td noWrap class="tdTitle">汇率</td>
                  <td noWrap class="td"><input type="text" name="hl" value='<%=masterRow.get("hl")%>' maxlength='<%=ds.getColumn("hl").getPrecision()%>' style="width:110" <%=edClass%> onKeyDown="return getNextElement();" onchange="hl_onchange();" <%=readonly%>></td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("je").getFieldname()%></td>
                  <td noWrap class="td"><input type="text" name="ybje" value='<%=masterRow.get("ybje")%>' maxlength='<%=ds.getColumn("ybje").getPrecision()%>' style="width:110" <%=edClass%> onKeyDown="return getNextElement();" onchange="cjyf_onchange()" <%=readonly%>></td>
                  <td noWrap class="tdTitle">冲减预付</td>
                  <td noWrap class="td"><input type="text" name="cjyf" value='<%=masterRow.get("cjyf")%>' maxlength='<%=ds.getColumn("cjyf").getPrecision()%>' style="width:110" <%=edClass%> onKeyDown="return getNextElement();" onchange="cjyf_onchange()" <%=readonly%>></td>
                  <td noWrap class="tdTitle">总付款金额</td>
                  <td noWrap class="td"><input type="text" name="zfkje" value='<%=masterRow.get("zfkje")%>' maxlength='<%=ds.getColumn("zfkje").getPrecision()%>' style="width:110" class=edline onKeyDown="return getNextElement();" readonly></td>
                 </tr>
                 <tr>
                  <td noWrap class="tdTitle">总人民币金额</td>
                  <td noWrap class="td"><input type="text" name="je" value='<%=masterRow.get("je")%>' maxlength='<%=ds.getColumn("je").getPrecision()%>' style="width:110" class=edline onKeyDown="return getNextElement();" readonly></td>
                  <td  noWrap class="tdTitle"><%=masterProducer.getFieldInfo("jsfsid").getFieldname()%></td>
                  <td  noWrap class="td">
                  <%
                    if(isEnd){
                      String jsfsid=masterRow.get("jsfsid");
                    %>
                    <input type="hidden" name="jsfsid" value='<%=masterRow.get("jsfsid")%>'>
                    <input type='text' value='<%=balanceModeBean.getLookupName(masterRow.get("jsfsid"))%>' style='width:110' class='edline' readonly>
                    <%}else {%>
                    <pc:select name="jsfsid"  style="width:110">
                    <%=balanceModeBean.getList(masterRow.get("jsfsid"))%>
                    </pc:select>
                 <%}%></td>
                  <td noWrap class="tdTitle">供货商开户行</td>
                  <td noWrap class="td"><input type="text" name="dfyh" value='<%=masterRow.get("dfyh")%>' maxlength='<%=ds.getColumn("dfyh").getPrecision()%>' style="width:110" <%=edClass%> onKeyDown="return getNextElement();"  <%=readonly%>></td>
                  <td noWrap class="tdTitle">供货商帐号</td>
                  <td noWrap class="td"><input type="text" name="dfzh" value='<%=masterRow.get("dfzh")%>' maxlength='<%=ds.getColumn("dfzh").getPrecision()%>' style="width:110" <%=edClass%> onKeyDown="return getNextElement();"  <%=readonly%>></td>
                 </tr>
                 <tr>
                  <td noWrap class="tdTitle">申请人</td>
                  <td   noWrap class="td">
                  <%if(isEnd){%>
                   <input type='text' value='<%=personBean.getLookupName(masterRow.get("personid"))%>' style='width:110' class='edline' readonly>
                   <input type="hidden" name="personid" value='<%=masterRow.get("personid")%>'>
                   <%
                  }else {%>
                  <pc:select name="personid" addNull="1" style="width:110">
                    <%=personBean.getList(masterRow.get("personid"),"deptid",masterRow.get("deptid"))%> </pc:select>
                   <%}%></td>


                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("yh").getFieldname()%></td>
                  <td noWrap class="td" >
                  <%if(isEnd)
                    {
                    out.print("<input type='text' value='"+masterRow.get("yh")+"' style='width:110' class='edline' readonly>");
                    }else
                    {String yh=masterRow.get("yh");%>
                  <pc:select name="yh" addNull="1" style="width:110"   onSelect="yhchange()"  combox="1" value="<%=yh%>">
                  <%=bankBean.getList()%> </pc:select>
                   <%}%></td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("zh").getFieldname()%></td>
                  <td noWrap class="td" >
                  <%if(isEnd) out.print("<input type='text' value='"+masterRow.get("zh")+"' style='width:110' class='edline' readonly>");
                  else {String zh=masterRow.get("zh");%>
                  <pc:select name="zh" addNull="1" style="width:110" combox="1" value="<%=zh%>">
                  <%=bankaccountBean.getList(masterRow.get("zh"),"yhmc",masterRow.get("yh"))%> </pc:select>
                   <%}%></td>
                 </tr>
                 <tr>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("bz").getFieldname()%></td>
                  <td  class="td" colspan="3"><input type="text" align="left" <%=edClass%> name="bz" value='<%=masterRow.get("bz")%>' maxlength='<%=ds.getColumn("bz").getPrecision()%>' style="width:100%"  onKeyDown="return getNextElement();"<%=readonly%>></td>
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
  function cjyf_onchange()
  {
    if(form1.ybje.value=="")
    {
      alert("请输入金额!");
      form1.cjyf.value="";
      return;
    }
    if(isNaN(form1.ybje.value)){
      alert("输入的金额非法");
      form1.ybje.focus();
      return;
    }
    if(isNaN(form1.cjyf.value)){
      alert("输入的冲减预付非法");
      form1.cjyf.focus();
      return;
    }

    /*
    if((parseFloat(form1.cjyf.value) > parseFloat(form1.je.value))){
      alert("输入的冲减预付非法");
      form1.cjyf.focus();
      return;
    }
    */
    if(!form1.ybje.value==""&&!form1.cjyf.value=="")
    {
    form1.zfkje.value = parseFloat(form1.ybje.value)+parseFloat(form1.cjyf.value);
    form1.je.value=formatQty(parseFloat(form1.zfkje.value)*parseFloat(form1.hl.value));
    }
  }

  function hl_onchange()
{
  var hlObj = form1.hl;
  if(hlObj.value=="")
    return;
  if(hlObj.value==0) {
    alert('汇率不能为零');
    return;
  }
  if(isNaN(hlObj.value)){
    alert('输入的汇率非法');
    return;
  }
  form1.je.value=formatQty(parseFloat(form1.zfkje.value)*parseFloat(hlObj.value));
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
      <%if(djxz.equals("2")){%>
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
    TdhwMultiSelect('form1','srcVar=tdhwids','fieldVar=tdid',form1.dwtxid.value,"sumitForm(<%=In_BuyBalanceBean.DETAIL_SALE_ADD%>,1)");
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
    OrderSingleSelect('form1','srcVar=selectedtdid','fieldVar=tdid',form1.dwtxid.value,"sumitForm(<%=In_BuyBalanceBean.IMPORT_TD%>,-1)");
  }

  function hl_onchange()
 {
   var hlObj = form1.hl;
   if(hlObj.value=="")
     return;
   if(hlObj.value==0) {
     alert('汇率不能为零');
     return;
   }
   if(isNaN(hlObj.value)){
     alert('输入的汇率非法');
     return;
   }
   for(k=0; k<<%=detailRows.length%>; k++)
   {
     cg_onchange(k);
   }
  }


  function je_onchange(i, isBigUnit)
{
 var ybjeObj = form1.ybje;
 var hlObj = form1.hl;
 var showText = "输入的金额非法";
 var showText2 ="输入的金额小于零";
 var changeObj =ybjeObj;
 if(obj.value=="")
   return;
 if(isNaN(obj.value))
 {
   alert(showText);
   obj.focus();
   return;
 }
 if(obj.value<=0)
 {
   alert(showText2);
   obj.focus();
   return;
 }

 if(isBigUnit && hlObj.value!="" && !isNaN(hlObj.value) && hlObj!="0")
   jeObj.value = formatSum(parseFloat(zfkjeObj.value) * parseFloat(hlObj.value));
 cal_tot('je');
  }
</script>
<%
//&#$
if(In_BuyBalanceBean.isApprove){%><jsp:include page="../pub/approve.jsp" flush="true"/><%}%>
<%out.print(retu);%>
</BODY>
</Html>