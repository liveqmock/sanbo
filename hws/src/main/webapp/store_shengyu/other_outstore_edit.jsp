<%--其它出库单表--%>
<%
/**
 * 2004-3-30 15:44 新增 给部门下拉表加上能使经手人跟随它自己不同部门而变的js函数 yjg
 * 2004-3-30 15:27 修改 javascript修改页面上可以输出数值的数量,换算数量栏位,
 *   数量,换算数量互动关系仅在如此情况下有效:当修改其中的一个如果另一个是空的话则跟随改变
 * 03.15 18:48 新增 新增打印单据按钮来把这张单据页面上的内容打印出来. yjg
 * 03.09 11:43 新增 新增关闭按钮提供给当此页面是被报表调用时使用. yjg
 * 03.09 11:43 修改 去掉定义widths[]数组的几行代码,同时修改t_hssl, t_sl, t_je的宽度为width:100% yjg
 * 03.09 12:06 修改 调整了表格中的规格属性, 数量,换算数量td的排列位置. 下面的具体显示这些值的jsp scripts也做了相应调整. yjg
 * 03.04 12:03 修改 注释掉下面这一段js.因为它会使换算数量和数量两个输出框中的值全都会改变.
 *                  这是mantis上大发专案中的 0000151  号bug.               yjg
 *
 */
%>
<%@ page contentType="text/html; charset=gb2312" %><%@ include file="../pub/init.jsp"%>
<%@ page import="engine.dataset.*,engine.project.Operate,java.math.BigDecimal,engine.html.*,java.util.ArrayList"%><%!
  String op_add    = "op_add";
  String op_delete = "op_delete";
  String op_edit   = "op_edit";
  String op_search = "op_search";
  String op_approve ="op_approve";
%><%
  engine.erp.store.shengyu.B_OtherOutStore b_OtherOutStoreBean = engine.erp.store.shengyu.B_OtherOutStore.getInstance(request);
  b_OtherOutStoreBean.djxz = 10;
  String pageCode = "other_outstore_list";
  //boolean hasApproveLimit = isApprove && loginBean.hasLimits(pageCode, op_approve);
%>
<html>
<head>
<title></title>
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
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
  location.href='other_outstore_list.jsp';
}
function productCodeSelect(obj, i)
{
  ProdCodeChange(document.all['prod'], obj.form.name, 'srcVar=cpid_'+i+'&srcVar=cpbm_'+i+'&srcVar=product_'+i+'&srcVar=jldw_'+i+'&srcVar=hsbl_'+i+'&srcVar=hsdw_'+i+'&srcVar=isprops_'+i+'&storeid='+form1.storeid.value,
                 'fieldVar=cpid&fieldVar=cpbm&fieldVar=product&fieldVar=jldw&fieldVar=hsbl&fieldVar=hsdw&fieldVar=isprops', obj.value, 'product_change('+i+')');
}
function productNameSelect(obj,i)
{
    ProdNameChange(document.all['prod'], obj.form.name, 'srcVar=cpid_'+i+'&srcVar=cpbm_'+i+'&srcVar=product_'+i+'&srcVar=jldw_'+i+'&srcVar=hsbl_'+i+'&srcVar=hsdw_'+i+'&srcVar=isprops_'+i+'&storeid='+form1.storeid.value,
               'fieldVar=cpid&fieldVar=cpbm&fieldVar=product&fieldVar=jldw&fieldVar=hsbl&fieldVar=hsdw&fieldVar=isprops', obj.value, 'product_change('+i+')');
}
function corpCodeSelect(obj)
{
  //02.18 15:47 CustomerCodeChange函数使用参数1与ProvideCodeChange函数功能是相同的.查找供应商 yjg
  CustomerCodeChange('1',document.all['prod'], obj.form.name, 'srcVar=dwtxid&srcVar=dwdm&srcVar=dwmc',
                 'fieldVar=dwtxid&fieldVar=dwdm&fieldVar=dwmc', obj.value, 'sumitForm(<%=b_OtherOutStoreBean.ONCHANGE%>)');
  //ProvideCodeChange(document.all['prod'], obj.form.name, 'srcVar=dwtxid&srcVar=dwdm&srcVar=dwmc',
                 //'fieldVar=dwtxid&fieldVar=dwdm&fieldVar=dwmc', obj.value, 'sumitForm(<%=b_OtherOutStoreBean.ONCHANGE%>)');
}

function corpNameSelect(obj)
{
     CustomerNameChange('1', document.all['prod'], obj.form.name, 'srcVar=dwtxid&srcVar=dwdm&srcVar=dwmc',
                 'fieldVar=dwtxid&fieldVar=dwdm&fieldVar=dwmc', obj.value, 'sumitForm(<%=b_OtherOutStoreBean.ONCHANGE%>)');
}
<%--2004-4-23 14:24新增 新增用于规格属性选择的js函数 yjg--%>
function propertyNameSelect(obj,cpid,i)
{
  PropertyNameChange(document.all['prod'], obj.form.name, 'srcVar=dmsxid_'+i+'&srcVar=sxz_'+i,
     'fieldVar=dmsxid&fieldVar=sxz', cpid, obj.value);
}
function product_change(i){
  document.all['dmsxid_'+i].value="";
  document.all['sxz_'+i].value="";
  //document.all['widths_'+i].value="";
  //associateSelect(document.all['prod'], '<%=engine.project.SysConstant.BEAN_TECHNICS_ROUTE%>', 'gylxid_'+i, 'cpid', eval('form1.cpid_'+i+'.value'), '', true);
}
</script>
<%String retu = b_OtherOutStoreBean.doService(request, response);
  if(retu.indexOf("backList();")>-1)
  {
    out.print(retu);
    return;
  }
  engine.project.LookUp buyOrderGoodsBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_BUY_ORDER_STOCK);//采购合同
  engine.project.LookUp corpBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_CORP);//LookUp往来单位
  engine.project.LookUp deptBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_DEPT);//LookUp部门信息
  engine.project.LookUp prodBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_PRODUCT);//LookUp产品信息
  engine.project.LookUp personBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_PERSON);//LookUp人员信息
  engine.project.LookUp storeBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_STORE);//LookUp仓库信息
  engine.project.LookUp propertyBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_SPEC_PROPERTY);//物资规格属性
  engine.project.LookUp balanceBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_BALANCE_MODE);//LookUp结算方式
  engine.project.LookUp saleoutBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_STORE_OTHER_OUT);//LookUp出库单单据类别
  engine.project.LookUp storeAreaBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_STORE_AREA);//LookUp库位信息
  String curUrl = request.getRequestURL().toString();
  EngineDataSet ds = b_OtherOutStoreBean.getMaterTable();//得到主表
  EngineDataSet list = b_OtherOutStoreBean.getDetailTable();//得到从表
  HtmlTableProducer masterProducer = b_OtherOutStoreBean.masterProducer;
  HtmlTableProducer detailProducer = b_OtherOutStoreBean.detailProducer;
  RowMap masterRow = b_OtherOutStoreBean.getMasterRowinfo();//主表行信息
  RowMap[] detailRows= b_OtherOutStoreBean.getDetailRowinfos();//从表行信息
  String bjfs = loginBean.getSystemParam("BUY_PRICLE_METHOD");//得到登陆用户报价方式的系统参数
  //boolean isHandwork = loginBean.getSystemParam("KC_HANDIN_STOCK_BILL").equals("1");//得到是否可以手工增加的系统参数
  String deptid = masterRow.get("deptid");//得到该单据的制单部门id
  String zdrid = masterRow.get("zdrid");//得到该单据的制单员id
  String loginId = b_OtherOutStoreBean.loginId;
  boolean isHasDeptLimit = loginBean.getUser().isDeptHandle(deptid, zdrid);//判断登陆员工是否有操作该制单人单据的权限
  String zt=masterRow.get("zt");
  if(b_OtherOutStoreBean.isApprove)
  {
    corpBean.regData(ds, "dwtxid");
    personBean.regData(ds, "personid");
  }
  boolean isEnd = b_OtherOutStoreBean.isReport || b_OtherOutStoreBean.isApprove || (!b_OtherOutStoreBean.masterIsAdd() && !zt.equals("0"));//表示已经审核或已完成
  boolean isCanDelete = !isEnd && !b_OtherOutStoreBean.masterIsAdd() && loginBean.hasLimits(pageCode, op_delete)
                        && loginId.equals(zdrid);//没有结束,在修改状态,并有删除权限,2004-08-04 并且登陆人等于制单人
  isEnd = isEnd
          || !(b_OtherOutStoreBean.masterIsAdd() ? loginBean.hasLimits(pageCode, op_add) : loginBean.hasLimits(pageCode, op_edit))
          || !loginId.equals(zdrid);//2004-08-04 新增 只有当前登陆人是制单人的时候才可以修改 yjg

  FieldInfo[] mBakFields = masterProducer.getBakFieldCodes();//主表用户的自定义字段
  String edClass = (isEnd || !isHasDeptLimit) ? "class=edline" : "class=edbox";
  String detailClass = (isEnd || !isHasDeptLimit) ? "class=ednone" : "class=edFocused";
  String detailClass_r = (isEnd || !isHasDeptLimit) ? "class=ednone_r" : "class=edFocused_r";
  String readonly = (isEnd || !isHasDeptLimit) ? " readonly" : "";
  //String needColor = isEnd ? "" : " style='color:#660000'";
  String title = zt.equals("1") ? ("已审核"/* 审核人:"+ds.getValue("shr")*/) : (zt.equals("9") ? "审批中" : (zt.equals("2")?"记帐":"未审核"));
  boolean isAdd = b_OtherOutStoreBean.isDetailAdd;
  String SC_STORE_UNIT_STYLE = loginBean.getSystemParam("SC_STORE_UNIT_STYLE");//计量单位和辅单位换算方式1=强制换算,0=仅空值时换算
%>
<BODY oncontextmenu="window.event.returnValue=true" onload="syncParentDiv('tableview1');">
<jsp:include page="../pub/scan_bar.jsp" flush="true"/>
<iframe id="prod" src="" width="95%" height=25 marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=no style="display:none"></iframe>
<form name="form1" action="<%=curUrl%>" method="POST" onsubmit="return false;" onKeyDown="return onInputKeyboard();">
  <table WIDTH="760" BORDER=0 CELLSPACING=0 CELLPADDING=0><tr>
    <td align="center" height="5"></td>
  </tr></table>
  <INPUT TYPE="HIDDEN" NAME="operate" value="">
  <INPUT TYPE="HIDDEN" NAME="rownum" value="">
  <table BORDER="0" CELLPADDING="1" CELLSPACING="0" align="center" width="760">
    <tr valign="top">
      <td><table border=0 CELLSPACING=0 CELLPADDING=0 class="table">
        <tr>
            <td class="activeVTab">其它出库单(<%=title%>)
            <%
              boolean isAtFirst = ds.atFirst();boolean isAtLast = ds.atLast();
              %>
              <%if (!isAtFirst)
              {%>
              <a href="#" title="到上一笔(ALT+Z)" onClick="sumitForm(<%=b_OtherOutStoreBean.PRIOR%>)">&lt</a>
              <pc:shortcut key='z' script='<%="sumitForm("+b_OtherOutStoreBean.PRIOR+")"%>'/>
             <%}%>
               <%if (!isAtLast)
              {%>
              <a href="#" title="到下一笔(ALT+X)" onClick="sumitForm(<%=b_OtherOutStoreBean.NEXT%>)">&gt</a>
              <pc:shortcut key='x' script='<%="sumitForm("+b_OtherOutStoreBean.NEXT+")"%>'/>
             <%}%>
            </td>
          </tr>
        </table>
        <table class="editformbox" CELLSPACING=1 CELLPADDING=0 >
          <tr>
            <td>
              <table CELLSPACING="1" CELLPADDING="1" BORDER="0" bgcolor="#f0f0f0">
                <%corpBean.regData(ds,"dwtxid");String jsr=masterRow.get("jsr");
                  if(!isEnd)
                    storeAreaBean.regConditionData(ds, "storeid");
                %>
                  <tr>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("sfdjdh").getFieldname()%></td>
                  <td noWrap class="td"><input type="text" name="sfdjdh" value='<%=masterRow.get("sfdjdh")%>' maxlength='<%=ds.getColumn("sfdjdh").getPrecision()%>' style="width:110" class="edline" onKeyDown="return getNextElement();" readonly></td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("sfrq").getFieldname()%></td>
                  <td noWrap class="td"><input type="text" name="sfrq" value='<%=masterRow.get("sfrq")%>' maxlength='10' style="width:90" <%=edClass%> onChange="checkDate(this)" onKeyDown="return getNextElement();"<%=readonly%>>
                    <%if(!isEnd && isHasDeptLimit){%>
                    <a href="#"><img align="absmiddle" src="../images/seldate.gif" width="20" height="16" border="0" title="选择日期" onclick="selectDate(form1.sfrq);"></a>
                    <%}%>
                  </td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("storeid").getFieldname()%></td>
                  <td  noWrap class="td">
                    <%String sumit = "if(form1.storeid.value!='"+masterRow.get("storeid")+"'){sumitForm("+b_OtherOutStoreBean.STORE_ONCHANGE+");}";%>
                    <%if(isEnd || !isHasDeptLimit) out.print("<input type='text' value='"+storeBean.getLookupName(masterRow.get("storeid"))+"' style='width:110' class='edline' readonly>");
                    else {%>
                    <pc:select name="storeid" addNull="1" style="width:110" onSelect="<%=sumit%>">
                      <%=storeBean.getList(masterRow.get("storeid"))%> </pc:select>
                    <%}%>
                  </td>
                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("deptid").getFieldname()%></td>
                  <td noWrap class="td">
                    <%if(isEnd || !isHasDeptLimit) out.print("<input type='text' value='"+deptBean.getLookupName(masterRow.get("deptid"))+"' style='width:110' class='edline' readonly>");
                    else {%>
                    <pc:select  name="deptid" addNull="1" style="width:110" onSelect="deptChange()"><%--2004-3-30 15:44 新增 给部门下拉表加上能使经手人跟随它自己不同部门而变的js函数 yjg--%>
                       <%=deptBean.getList(masterRow.get("deptid"))%>
                    </pc:select>
                    <%}%>
                  </td>
                </tr>
                <tr>

                  <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("jsr").getFieldname()%></td>
                  <td class="td" nowrap>
                  <%if(isEnd){%> <input type="text" name="jsr" value='<%=masterRow.get("jsr")%>' maxlength='<%=ds.getColumn("jsr").getPrecision()%>' style="width:110" class="edline" onKeyDown="return getNextElement();" readonly>
                  <%}else {%><%--2004-4-23 21:36 修改 销售出库单经手人默认为空 yjg--%>
                  <pc:select combox="1" className="edFocused" name="jsr" value="<%=jsr%>" style="width:110">
                  <%=personBean.getList()%></pc:select>
                  <%}%>
                  </td>
                   <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("bz").getFieldname()%></td>
                  <td noWrap class="td" colspan="3"><input type="text" name="bz" value='<%=masterRow.get("bz")%>' maxlength='<%=ds.getColumn("bz").getPrecision()%>' style="width:280" class="edbox" onKeyDown="return getNextElement();" <%=readonly%>>
                  </td>
                  </tr>
                <%/*打印用户自定义信息*/
                int j=0;
                while(j < mBakFields.length){
                  out.print("<tr>");
                  for(int k=0; k<4; k++)
                  {
                    out.print("<td noWrap class='tdTitle'>");
                    out.print(j < mBakFields.length ? mBakFields[j].getFieldname() : "&nbsp;");
                    out.print("</td><td noWrap class='td'");
                    if(j < mBakFields.length)
                    {
                      boolean isMemo = mBakFields[j].getType() == FieldInfo.MEMO_TYPE;
                      out.print(isMemo ? " colspan=7>" : ">");
                      String filedcode = mBakFields[j].getFieldcode();
                      String style = (isMemo ? "style='width:690'" : "style='width:110'")+ " onKeyDown='return getNextElement();'";
                      out.print(masterProducer.getFieldInput(mBakFields[j], masterRow.get(filedcode), filedcode, style, isEnd, true));
                      out.print("</td>");
                      if(isMemo)
                        break;
                    }
                    else
                      out.print(">&nbsp;</td>");
                    j++;
                  }
                  out.println("</tr>");
                }
                int width = (detailRows.length > 4 ? detailRows.length : 4)*23 + 66;
                %>
                <tr>
                  <td colspan="8" noWrap class="td"><div style="display:block;width:750;height=<%=width%>;overflow-y:auto;overflow-x:auto;">
                    <table id="tableview1" width="750" border="0" cellspacing="1" cellpadding="1" class="table" align="center">
                      <tr class="tableTitle">
                        <td nowrap width=10></td>
                        <td height='20' align="center" nowrap>
                          <%if(!isEnd && isHasDeptLimit){%>
                          <input name="image" class="img" type="image" title="新增(ALT+A)" onClick="buttonEventA()" src="../images/add_big.gif" border="0">
                           <pc:shortcut key="a" script='buttonEventA()'/>
                          <%}%>
                        </td>
                        <%
                        for (int i=0;i<detailProducer.getFieldInfo("cpid").getShowFieldNames().length;i++)
                          out.println("<td nowrap>"+detailProducer.getFieldInfo("cpid").getShowFieldName(i)+"<//td>");
                        %>
                        <td nowrap><%=detailProducer.getFieldInfo("dmsxid").getFieldname()%></td>
                        <td nowrap><%=detailProducer.getFieldInfo("sl").getFieldname()%></td>
                        <td nowrap>计量单位</td>
                        <td nowrap><%=detailProducer.getFieldInfo("hssl").getFieldname()%></td>
                        <td nowrap>换算单位</td>
                        <td nowrap><%=detailProducer.getFieldInfo("ph").getFieldname()%></td>
                        <td nowrap><%=detailProducer.getFieldInfo("kwid").getFieldname()%></td>
                        <td nowrap><%=detailProducer.getFieldInfo("bz").getFieldname()%></td>
                      </tr>
                    <%prodBean.regData(list,"cpid");
                      buyOrderGoodsBean.regData(list,"wjid");
                      propertyBean.regData(list,"dmsxid");
                      BigDecimal t_sl = new BigDecimal(0), t_je = new BigDecimal(0), t_hssl = new BigDecimal(0);
                      int i=0;
                      RowMap detail = null;
                      for(; i<detailRows.length; i++)   {
                        detail = detailRows[i];
                        String sl = detail.get("sl");
                        if(b_OtherOutStoreBean.isDouble(sl))
                          t_sl = t_sl.add(new BigDecimal(sl));
                        String hssl = detail.get("hssl");
                        if(b_OtherOutStoreBean.isDouble(hssl))
                          t_hssl = t_hssl.add(new BigDecimal(hssl));
                        String je = detail.get("je");
                        if(b_OtherOutStoreBean.isDouble(je))
                          t_je = t_je.add(new BigDecimal(je));
                        String kwName = "kwid_"+i;
                        String dmsxidName = "dmsxid_"+i;
                        String wjid=detail.get("wjid");
                        boolean isimport = !wjid.equals("");//引出采购进货单，从表产品编码当前行不能修改
                        String cpid = detail.get("cpid");
                        String Class = isimport  ? "class=ednone" : detailClass;//从表Class模式
                    %>
                      <tr id="rowinfo_<%=i%>" onClick="showDetail()">
                        <td class="td" nowrap><%=i+1%></td>
                        <td class="td" nowrap align="center">
                        <iframe id="prod_<%=i%>" src="" width="95%" height=25 marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=no style="display:none"></iframe>
                          <%if(!isEnd && !isimport && isHasDeptLimit){%>
                          <input type="hidden" name="singleIdInput_<%=i%>" value="">
                          <input name="image" class="img" type="image" title="单选物资" src="../images/select_prod.gif" border="0"
                          onClick="ProdSingleSelect('form1','srcVar=cpid_<%=i%>&srcVar=cpbm_<%=i%>&srcVar=product_<%=i%>&srcVar=jldw_<%=i%>&srcVar=hsdw_<%=i%>&srcVar=hsbl_<%=i%>&srcVar=isprops_<%=i%>',
                               'fieldVar=cpid&fieldVar=cpbm&fieldVar=product&fieldVar=jldw&fieldVar=hsdw&fieldVar=hsbl&fieldVar=isprops','&storeid='+form1.storeid.value,'product_change(<%=i%>)')">
                          <%}if(!isEnd && isHasDeptLimit){%>
                          <input name="image" class="img" type="image" title="删除" onClick="if(confirm('是否删除该记录？')) sumitForm(<%=Operate.DETAIL_DEL%>,<%=i%>)" src="../images/delete.gif" border="0">
                          <%}%>
                        </td><%RowMap  prodRow= prodBean.getLookupRow(detail.get("cpid"));
                          String hsbl = prodRow.get("hsbl");
                          String isprop = prodRow.get("isprops");
                          detail.put("hsbl",hsbl);
                         %>
                        <% RowMap buyOrderGoodsRow=buyOrderGoodsBean.getLookupRow(detail.get("wjid"));%>
                        <td class="td" nowrap>
                         <input type="hidden" name="cpid_<%=i%>" value="<%=detail.get("cpid")%>">
                         <input type="hidden" name="isbatchno_<%=i%>" value="<%=prodRow.get("isbatchno")%>">
                         <input type="text" <%=Class%>  onKeyDown="return getNextElement();" id="cpbm_<%=i%>" name="cpbm_<%=i%>" value='<%=prodRow.get("cpbm")%>' onchange="productCodeSelect(this,<%=i%>)" <%=isimport ? "readonly" : readonly%>>
                         <input type='hidden' id='hsbl_<%=i%>' name='hsbl_<%=i%>' value='<%=prodRow.get("hsbl")%>'>
                         <input type='hidden' id='truebl_<%=i%>' name='truebl_<%=i%>' value=''>
                         <input type="hidden" name="isprops_<%=i%>" value="<%=prodRow.get("isprops")%>">
                        </td>
                        <td class="td" nowrap><input type="text" <%=Class%>  onKeyDown="return getNextElement();" id="product_<%=i%>" name="product_<%=i%>" value='<%=prodRow.get("product")%>' onchange="productNameSelect(this,<%=i%>)" <%=isimport ? "readonly" : readonly%>></td>
                         <%--03.09 12:06 修改 调整了表格中的规格属性, 数量,换算数量td的排列位置. 下面的具体显示这些值的jsp scripts也做了相应调整. yjg--%>
                         <%--03.05 18:21 新增 修改规格属性为可输入的.并且新增onChange时的函数.yjg--%>
                        <td class="td" nowrap><input <%=detailClass%>  name="sxz_<%=i%>" value='<%=propertyBean.getLookupName(detail.get("dmsxid"))%>'
                           onchange="if(form1.cpid_<%=i%>.value==''){alert('请先输入产品');return;} propertyNameSelect(this,form1.cpid_<%=i%>.value,<%=i%>)" onKeyDown="return getNextElement();" <%=(!isEnd) ? "": "readonly"%>>
                        <input type="hidden" id="dmsxid_<%=i%>" name="dmsxid_<%=i%>" value="<%=detail.get("dmsxid")%>">
                        <%if(!isEnd){%>
                        <img style='cursor:hand' src='../images/view.gif' border=0 onClick="if(form1.cpid_<%=i%>.value==''){alert('请先输入产品');return;}if(form1.isprops_<%=i%>=='0'){alert('该物资没有规格属性');return;}PropertySelect('form1','dmsxid_<%=i%>','sxz_<%=i%>',form1.cpid_<%=i%>.value)">
                        <img style='cursor:hand' src='../images/delete.gif' BORDER=0 ONCLICK="dmsxid_<%=i%>.value='';sxz_<%=i%>.value='';">
                        <%}%>
                        </td>
                        <td class="td" nowrap><input type="text" <%=detailClass_r%>  onKeyDown="return getNextElement();" id="sl_<%=i%>" name="sl_<%=i%>" value='<%=detail.get("sl")%>' maxlength='<%=list.getColumn("sl").getPrecision()%>' onchange="sl_onchange(<%=i%>, false)" <%=readonly%>></td>
                         <td class="td" nowrap><input type="text" class=ednone  onKeyDown="return getNextElement();" id="jldw_<%=i%>" name="jldw_<%=i%>" value='<%=prodRow.get("jldw")%>' readonly></td>
                         <td class="td" nowrap><input type="text" <%=detailClass_r%>  onKeyDown="return getNextElement();" id="hssl_<%=i%>" name="hssl_<%=i%>" value='<%=detail.get("hssl")%>' maxlength='<%=list.getColumn("hssl").getPrecision()%>' onchange="sl_onchange(<%=i%>, true)" <%=readonly%>></td>
                         <td class="td" nowrap><input type="text" class=ednone  onKeyDown="return getNextElement();" id="hsdw_<%=i%>" name="hsdw_<%=i%>" value='<%=prodRow.get("hsdw")%>' readonly></td>
                         <input type="hidden" <%=detailClass_r%>  onKeyDown="return getNextElement();" id="dj_<%=i%>" name="dj_<%=i%>" value='<%=detail.get("dj")%>' maxlength='<%=list.getColumn("dj").getPrecision()%>' onchange="sl_onchange(<%=i%>, false)" <%=readonly%>>
                         <input type="hidden" class=ednone_r yDown="return getNextElement();" id="je_<%=i%>" name="je_<%=i%>" value='<%=detail.get("je")%>' maxlength='<%=list.getColumn("je").getPrecision()%>' readonly>
                         </td>
                        <td class="td" nowrap><input type="text" <%=detailClass%>  onKeyDown="return getNextElement();" id="ph_<%=i%>" name="ph_<%=i%>" value='<%=detail.get("ph")%>' maxlength='<%=list.getColumn("ph").getPrecision()%>'<%=readonly%>></td>
                        <td class="td" nowrap>
                        <%if(isEnd) out.print("<input type='text' name="+kwName+" value='"+storeAreaBean.getLookupName(detail.get("kwid"))+"' class='ednone' readonly>");
                        else {%>
                        <pc:select addNull="1" className="edFocused" name="<%=kwName%>">
                        <%=storeAreaBean.getList(detail.get("kwid"), "storeid", masterRow.get("storeid"))%></pc:select>
                        <%}%>
                        </td>
                        <td class="td" nowrap align="right"><input type="text" <%=detailClass%>  onKeyDown="return getNextElement();" name="bz_<%=i%>" id="bz_<%=i%>" value='<%=detail.get("bz")%>' maxlength='<%=list.getColumn("bz").getPrecision()%>'<%=readonly%>></td>
                      </tr>
                      <%list.next();
                        }
                        for(; i < 4; i++){
                  %>
                      <tr id="rowinfo_<%=i%>">
                        <td class="td">&nbsp;</td><td class="td">&nbsp;</td><td class="td">&nbsp;</td><td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td><td class="td">&nbsp;</td><td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td><td class="td">&nbsp;</td><td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td><td class="td">&nbsp;</td>
                        <%detailProducer.printBlankCells(pageContext, "class=td", true);%>
                      </tr>
                      <%}%>
                      <tr id="rowinfo_end">
                        <td class="td">&nbsp;</td>
                        <td class="tdTitle" nowrap>合计</td>
                        <td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td>
                        <td class="td"><input id="t_sl" name="t_sl" type="text" class="ednone_r" style="width:100%" value='<%=t_sl%>' readonly></td>
                        <td align="right" class="td">&nbsp;</td>
                       <td align="right" class="td"><input id="t_hssl" name="t_hssl" type="text" class="ednone_r" style="width:100%" value='<%=t_hssl%>' readonly></td>
                        <td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td>
                   <td align="right" class="td">
                            <input id="t_je" name="t_je" type="hidden" class="ednone_r" style="width:100%" value='<%=t_je%>' readonly>
                        </td>
                       <td class="td">&nbsp;</td>

                      </tr>
                    </table></div>
                    </td>
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
            <td class="td"><b>登记日期:</b><%=masterRow.get("zdrq")%></td>
            <td class="td"></td>
            <td class="td" align="right"><b>制单人:</b><%=masterRow.get("zdr")%></td>
          </tr>
          <tr>
            <td colspan="3" noWrap class="tableTitle">
             <%if(!isEnd && isHasDeptLimit){%>
              <input type="hidden" name="singleOrderGoods" value="" >
              <input type="hidden" name="scanValue" value="">
                <%--
              <input type="button" class="button" title="盘点机(E)" value="盘点机(E)" onClick="buttonEventE()">
                <pc:shortcut key="e" script='<%="buttonEventE()"%>'/>
                --%>
              <input name="button2" type="button" class="button" title="保存添加(ALT+N)" value="保存添加(N)" onClick="sumitForm(<%=Operate.POST_CONTINUE%>);">
                <pc:shortcut key="n" script='<%="sumitForm("+Operate.POST_CONTINUE+")"%>'/>
              <input name="btnback" type="button" class="button" title="保存ALT+S)" value="保存(S)" onClick="sumitForm(<%=Operate.POST%>);">
                <pc:shortcut key="s" script='<%="sumitForm("+Operate.POST+")"%>'/>
              <%}%>
              <%--02.23 11:46 新增 新增显示下面这几个按钮的条件中加上isReport条件 yjg--%>
              <%if(isCanDelete && isHasDeptLimit && !b_OtherOutStoreBean.isReport){%>
                  <input name="button3" type="button" class="button" title="删除(ALT+D)" value="删除(D)" onClick="buttonEventD();">
                  <pc:shortcut key="d" script="buttonEventD()"/>
             <%}%>
              <%if(!b_OtherOutStoreBean.isApprove && !b_OtherOutStoreBean.isReport){%>
                 <input name="btnback" type="button" class="button" title="返回(ALT+C)" value="返回(C)" onClick="backList();">
                 <pc:shortcut key="c" script='<%="backList()"%>'/>
             <%}%>
              <%--03.09 11:43 新增 新增关闭按钮提供给当此页面是被报表调用时使用. yjg--%>
            <%if(b_OtherOutStoreBean.isReport){%>
                 <input name="btnback" type="button" class="button" title="关闭(ALT+T)" value="关闭(T)" onClick="window.close()">
                 <pc:shortcut key="t" script='<%="window.close()"%>'/>
            <%}%>
                <%--03.15 18:48 新增 新增打印单据按钮来把这张单据页面上的内容打印出来. yjg--%>
             <input type="button" class="button" title="打印(ALT+P)" value="打印(P)" onclick="buttonEventP()">
                <pc:shortcut key="p" script='<%="buttonEventP()"%>'/>
            </td>
          </tr>
        </table></td>
    </tr>
  </table>
</form>
<script language="javascript">initDefaultTableRow('tableview1',1);
<%=b_OtherOutStoreBean.adjustInputSize(new String[]{"cpbm","product","jldw", "ph", "hssl", "sl", "dj", "je", "sxz", "bz", "kwid"},  "form1", detailRows.length)%>
  function formatQty(srcStr){ return formatNumber(srcStr, '<%=loginBean.getQtyFormat()%>');}
  function formatPrice(srcStr){ return formatNumber(srcStr, '<%=loginBean.getPriceFormat()%>');}
  function formatSum(srcStr){ return formatNumber(srcStr, '<%=loginBean.getSumFormat()%>');}
    function sl_onchange(i, isBigUnit)
    {
       var oldhsblObj = document.all['hsbl_'+i];
       var sxzObj = document.all['sxz_'+i];
       unitConvert(document.all['prod_'+i], 'form1', 'srcVar=truebl_'+i, 'exp='+oldhsblObj.value, sxzObj.value, 'nsl_onchange('+i+','+isBigUnit+')');
   }
    function nsl_onchange(i, isBigUnit)
  {
    var slObj = document.all['sl_'+i];
    //var hsblObj = document.all['hsbl_'+i];
    var hsblObj = document.all['truebl_'+i];
    var hsslObj = document.all['hssl_'+i];
    var djObj = document.all['dj_'+i];
    var jeObj = document.all['je_'+i];
    var bjfs = <%=bjfs%>;

    var obj = isBigUnit ? hsslObj : slObj;
    var showText = isBigUnit ? "输入的换算数量非法" : "输入的数量非法";
    var changeObj = isBigUnit ? slObj : hsslObj;
    if(obj.value=="")
      return;
    if(isNaN(obj.value))
    {
      alert(showText);
      obj.focus();
      return;
    }
    //2004-3-30 15:27 修改 javascript修改页面上可以输入数值的数量,换算数量栏位,
  //数量,换算数量互动关系仅在如此情况下有效:当修改其中的一个如果另一个是空的话则跟随改变
  if(!(changeObj.value!="" && '<%=SC_STORE_UNIT_STYLE%>'!='1'))//是否强制转换
  {
    if(hsblObj.value!="" && !isNaN(hsblObj.value)){
      changeObj.value = formatPrice(isBigUnit ? (parseFloat(hsslObj.value)*parseFloat(hsblObj.value)) : (parseFloat(slObj.value)/parseFloat(hsblObj.value)));
      <%--03.04 12:03 修改 注释掉下面这一段js.因为它会使换算数量和数量两个输入框中的值全都会改变.  yjg--%>
      //if(isBigUnit)
      // hsslObj.value=changeObj.value;
      //else
      // slObj.value=changeObj.value;
    }
  }
    if(isNaN(djObj.value))
    {
      alert('输入的单价非法');
      return;
    }
    if(djObj.value=="")
      return;
    if(bjfs==1)
      jeObj.value=formatPrice(parseFloat(hsslObj.value)*parseFloat(djObj.value));
    if(bjfs==0)
      jeObj.value=formatPrice(parseFloat(slObj.value)*parseFloat(djObj.value));
    cal_tot('je');
    cal_tot('sl');
    cal_tot('hssl');

  }
    function cal_tot(type)
    {
      var tmpObj;
      var tot=0;
      for(i=0; i<<%=detailRows.length%>; i++)
      {
        if(type == 'sl')
          tmpObj = document.all['sl_'+i];
        else if(type == 'hssl')
          tmpObj = document.all['hssl_'+i];
        else if(type == 'je')
          tmpObj = document.all['je_'+i];
        else
          return;
        if(tmpObj.value!="" && !isNaN(tmpObj.value))
          tot += parseFloat(tmpObj.value);
      }
      if(type == 'sl')
        document.all['t_sl'].value = formatQty(tot);
      else if(type == 'hssl')
        document.all['t_hssl'].value = formatQty(tot);
      else if(type == 'je')
        document.all['t_je'].value = formatQty(tot);
    }
  function OrderGoodsMultiSelect(frmName, srcVar, methodName,notin)
 {
   var winopt = "location=no scrollbars=yes menubar=no status=no resizable=1 width=790 height=570 top=0 left=0";
   var winName= "GoodsProdSelector";
   paraStr = "../store/import_ordergoods_select.jsp?operate=0&srcFrm="+frmName+"&"+srcVar;
   if(methodName+'' != 'undefined')
     paraStr += "&method="+methodName;
   if(notin+'' != 'undefined')
   paraStr += "&notin="+notin;
   newWin =window.open(paraStr,winName,winopt);
   newWin.focus();
  }
  function OrderGoodsSingleSelect(frmName,srcVar,fieldVar,curID,storeid,methodName,notin)
  {
    var winopt = "location=no scrollbars=yes menubar=no status=no resizable=1 width=790 height=570 top=0 left=0";
    var winName= "OrderSingleSelector";
    paraStr = "../store/ordergoods_single_select.jsp?operate=0&srcFrm="+frmName+"&"+srcVar+"&"+fieldVar+"&dwtxid="+curID+"&storeid="+storeid;
    if(methodName+'' != 'undefined')
      paraStr += "&method="+methodName;
    if(notin+'' != 'undefined')
    paraStr += "&notin="+notin;
    newWin =window.open(paraStr,winName,winopt);
    newWin.focus();
  }
  function transferScan()//调用盘点机
  {
    //alert(scaner.Read('<%=engine.util.StringUtils.replace(curUrl, "contract_instore_edit", "IT3CW32d.DLL")%>'));
    var scanValueObj = form1.scanValue;
    scanValueObj.value = scaner.Read('<%=engine.util.StringUtils.replace(curUrl, "contract_instore_edit.jsp", "IT3CW32d.DLL")%>');//得到包含产品编码和批号的字符串
    if(scanValueObj.value=='')
      return;
    sumitForm(<%=b_OtherOutStoreBean.TRANSFERSCAN%>);
  }
  //盘点机事件.
  function buttonEventE()
  {
    if(form1.storeid.value==''){alert('请选择仓库');return;}transferScan();
  }
  //删除
  function buttonEventD()
  {
   if(confirm('是否删除该记录？'))sumitForm(<%=Operate.DEL%>);
  }
  //打印
 function buttonEventP()
 {
    location.href='../pub/pdfprint.jsp?code=other_instore_edit_bill&operate=<%=b_OtherOutStoreBean.PRINT_BILL%>&a$sfdjid=<%=masterRow.get("sfdjid")%>&src=../store/other_instore_edit.jsp';
 }
//新增
 function buttonEventA()
 {
    if(form1.storeid.value==''){alert('请选择仓库');return;}sumitForm(<%=Operate.DETAIL_ADD%>);
 }
 //2004-3-30 15:44 新增 给部门下拉表加上能使经手人跟随它自己不同部门而变的js函数 yjg
function deptChange()
{
 associateSelect(document.all['prod'], '<%=engine.project.SysConstant.BEAN_PERSON%>', 'jsr', 'deptid', eval('form1.deptid.value'), '');
 }
   function showDetail(masterRow){
    selectRow();
  }
</script>
<%if(b_OtherOutStoreBean.isApprove){%><jsp:include page="../pub/approve.jsp" flush="true"/>
<%}%>
<%out.print(retu);%>
</BODY>
</Html>