///-----------------------
/// prog mdlPanel
///-----------------------

const std = @import("std");

// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;

// error
const msgerr = @import("forms").ErrForms;
const dsperr = @import("forms").dsperr;

// full delete for produc
const forms = @import("forms");

// frame
const frm = @import("forms").frm;
// panel
const pnl = @import("forms").pnl;
// button
const btn = @import("forms").btn;
// label
const lbl = @import("forms").lbl;
// flied
const fld = @import("forms").fld;
// line horizontal
const lnh = @import("forms").lnh;
// line vertival
const lnv = @import("forms").lnv;

// grid
const grd = @import("grid").grd;
// menu
const mnu = @import("menu").mnu;


// tools utility
const utl = @import("utils");

// tools regex
const reg = @import("mvzr");



//var numPanel : usize = undefined ;

pub const ErrMain = error{
    main_append_NPANEL_invalide,
    main_run_EnumFunc_invalide,
    main_run_EnumTask_invalide,
    main_loadPanel_allocPrint_invalide,
    main_updatePanel_allocPrint_invalide,
    main_NPANEL_invalide,
};



const lp01 = enum {
    F_shw,
    F_chk,
    F_txt,
    F_shw2,
    F_chk2,
    F_txt2,
    alt_shw,
    alt_chk,
    alt_txt,
    ctrl_shw,
    ctrl_chk,
    ctrl_txt,
    lnh1,
    lnv1,
    lnv2,
    lnv3,
};
// field panel pFmt01
const    fp01 = enum (u9)    {
    name  = 0 ,
    posx  ,
    posy  , 
    lines ,
    cols  ,
    cadre ,
    title ,
// field function F01..F24

    F1 ,
    F1_shw,
    F1_chk,
    F1_txt,
    F2,
    F2_shw,
    F2_chk,
    F2_txt,
    F3,
    F3_shw,
    F3_chk,
    F3_txt,
    F4,
    F4_shw,
    F4_chk,
    F4_txt,
    F5,
    F5_shw,
    F5_chk,
    F5_txt,
    F6,
    F6_shw,
    F6_chk,
    F6_txt,
    F7,
    F7_shw,
    F7_chk,
    F7_txt,
    F8,
    F8_shw,
    F8_chk,

    F8_txt,
    F9,
    F9_shw,
    F9_chk,
    F9_txt,
    F10,
    F10_shw,
    F10_chk,
    F10_txt,
    F11,
    F11_shw,
    F11_chk,
    F11_txt,
    F12,
    F12_shw,
    F12_chk,
    F12_txt,
    F13,
    F13_shw,
    F13_chk,
    F13_txt,
    F14,
    F14_shw,
    F14_chk,
    F14_txt,
    F15,
    F15_shw,
    F15_chk,
    F15_txt,
    F16,
    F16_shw,
    F16_chk,
    F16_txt,
    F17,
    F17_shw,
    F17_chk,
    F17_txt,
    F18,
    F18_shw,
    F18_chk,
    F18_txt,
    F19,
    F19_shw,
    F19_chk,
    F19_txt,
    F20,
    F20_shw,
    F20_chk,
    F20_txt,
    F21,
    F21_shw,
    F21_chk,
    F21_txt,
    F22,
    F22_shw,
    F22_chk,
    F22_txt,
    F23,
    F23_shw,
    F23_chk,
    F23_txt,
    F24,
    F24_shw,
    F24_chk,
    F24_txt,
    F25,
    F25_shw,
    F25_chk,
    F25_txt,
    F26,
    F26_shw,
    F26_chk,
    F26_txt,
    F27,
    F27_shw,
    F27_chk,
    F27_txt,
    F28,
    F28_shw,
    F28_chk,
    F28_txt,
    F29,
    F29_shw,
    F29_chk,
    F29_txt,
    F30,
    F30_shw,
    F30_chk,
    F30_txt,
    F31,
    F31_shw,
    F31_chk,
    F31_txt,
    F32,
    F32_shw,
    F32_chk,
    F32_txt,
    F33,
    F33_shw,
    F33_chk,
    F33_txt,
    F34,
    F34_shw,
    F34_chk,
    F34_txt,
    F35,
    F35_shw,
    F35_chk,
    F35_txt,
    F36,
    F36_shw,
    F36_chk,
    F36_txt,

    // field function altA..altZ
    altA ,
    altA_shw,
    altA_chk,
    altA_txt,
    altB,
    altB_shw,
    altB_chk,
    altB_txt,
    altC,
    altC_shw,
    altC_chk,
    altC_txt,
    altD,
    altD_shw,
    altD_chk,
    altD_txt,
    altE,
    altE_shw,
    altE_chk,
    altE_txt,
    altF,
    altF_shw,
    altF_chk,
    altF_txt,
    altG,
    altG_shw,
    altG_chk,
    altG_txt,
    altH,
    altH_shw,
    altH_chk,
    altH_txt,
    altI,
    altI_shw,
    altI_chk,
    altI_txt,
    altJ,
    altJ_shw,
    altJ_chk,
    altJ_txt,
    altK,
    altK_shw,
    altK_chk,
    altK_txt,
    altL,
    altL_shw,
    altL_chk,
    altL_txt,
    altM,
    altM_shw,
    altM_chk,
    altM_txt,
    altN,
    altN_shw,
    altN_chk,
    altN_txt,
    altO,
    altO_shw,
    altO_chk,
    altO_txt,
    altP,
    altP_shw,
    altP_chk,
    altP_txt,
    altQ,
    altQ_shw,
    altQ_chk,
    altQ_txt,
    altR,
    altR_shw,
    altR_chk,
    altR_txt,
    altS,
    altS_shw,
    altS_chk,
    altS_txt,
    altT,
    altT_shw,
    altT_chk,
    altT_txt,
    altU,
    altU_shw,
    altU_chk,
    altU_txt,
    altV,
    altV_shw,
    altV_chk,
    altV_txt,
    altW,
    altW_shw,
    altW_chk,
    altW_txt,
    altX,
    altX_shw,
    altX_chk,
    altX_txt,
    altY,
    altY_shw,
    altY_chk,
    altY_txt,
    altZ,
    altZ_shw,
    altZ_chk,
    altZ_txt,

// field function ctrlA..ctrlZ

    ctrlA ,
    ctrlA_shw,
    ctrlA_chk,
    ctrlA_txt,
    ctrlB,
    ctrlB_shw,
    ctrlB_chk,
    ctrlB_txt,
    ctrlC,
    ctrlC_shw,
    ctrlC_chk,
    ctrlC_txt,
    ctrlD,
    ctrlD_shw,
    ctrlD_chk,
    ctrlD_txt,
    ctrlE,
    ctrlE_shw,
    ctrlE_chk,
    ctrlE_txt,
    ctrlF,
    ctrlF_shw,
    ctrlF_chk,
    ctrlF_txt,
    ctrlG,
    ctrlG_shw,
    ctrlG_chk,
    ctrlG_txt,
    ctrlH,
    ctrlH_shw,
    ctrlH_chk,
    ctrlH_txt,
    ctrlI,
    ctrlI_shw,
    ctrlI_chk,
    ctrlI_txt,
    ctrlJ,
    ctrlJ_shw,
    ctrlJ_chk,
    ctrlJ_txt,
    ctrlK,
    ctrlK_shw,
    ctrlK_chk,
    ctrlK_txt,
    ctrlL,
    ctrlL_shw,
    ctrlL_chk,
    ctrlL_txt,
    ctrlM,
    ctrlM_shw,
    ctrlM_chk,
    ctrlM_txt,
    ctrlN,
    ctrlN_shw,
    ctrlN_chk,
    ctrlN_txt,
    ctrlO,
    ctrlO_shw,
    ctrlO_chk,
    ctrlO_txt,
    ctrlP,
    ctrlP_shw,
    ctrlP_chk,
    ctrlP_txt,
    ctrlQ,
    ctrlQ_shw,
    ctrlQ_chk,
    ctrlQ_txt,
    ctrlR,
    ctrlR_shw,
    ctrlR_chk,
    ctrlR_txt,
    ctrlS,
    ctrlS_shw,
    ctrlS_chk,
    ctrlS_txt,
    ctrlT,
    ctrlT_shw,
    ctrlT_chk,
    ctrlT_txt,
    ctrlU,
    ctrlU_shw,
    ctrlU_chk,
    ctrlU_txt,
    ctrlV,
    ctrlV_shw,
    ctrlV_chk,
    ctrlV_txt,
    ctrlW,
    ctrlW_shw,
    ctrlW_chk,
    ctrlW_txt,
    ctrlX,
    ctrlX_shw,
    ctrlX_chk,
    ctrlX_txt,
    ctrlY,
    ctrlY_shw,
    ctrlY_chk,
    ctrlY_txt,
    ctrlZ,
    ctrlZ_shw,
    ctrlZ_chk,
    ctrlZ_txt
};







pub fn Panel_Fmt01() *pnl.PANEL {
    const termSize = term.getSize() ;


    var Panel : *pnl.PANEL = pnl.newPanelC("FRAM01",
                                        1, 1,
                                        termSize.height,
                                        termSize.width ,
                                        forms.CADRE.line1,
                                        "Def.Panel"
                                        );

    Panel.button.append(btn.newButton(
                                    kbd.F1,            // function
                                    true,            // show
                                    true,            // check field
                                    "help",            // title 
                                    )
                                ) catch unreachable ;

    Panel.button.append(btn.newButton(
                                    kbd.F2,            // function
                                    true,            // show
                                    true,            // check field
                                    "Test",            // title 
                                    )
                                ) catch unreachable ;

    Panel.button.append(btn.newButton(
                                    kbd.F6,            // function
                                    true,            // show
                                    true,            // check field
                                    "Qry_Panel",    // title 
                                    )
                                ) catch unreachable ;

    Panel.button.append(btn.newButton(
                                    kbd.F9,            // function
                                    true,            // show
                                    true,            // check field
                                    "Add",            // title 
                                    )
                                ) catch unreachable ;

    Panel.button.append(btn.newButton(
                                    kbd.F11,        // function
                                    true,            // show
                                    true,            // check field
                                    "Update",        // title 
                                    )
                                ) catch unreachable ;

    Panel.button.append(btn.newButton(
                                    kbd.F12,        // function
                                    true,            // show
                                    false,            // check field
                                    "Return",        // title 
                                    )
                                ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.name)     ,2,2, "name.....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp01.posx)     ,3,2, "posX.....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp01.posy)     ,4,2, "posy.....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp01.lines) ,5,2, "lines....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp01.cols)     ,6,2, "cols.....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp01.cadre) ,7,2, "cadre....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp01.title) ,8,2, "title....:") ) catch unreachable ;

    Panel.field.append(fld.newFieldAlphaNumeric(@tagName(fp01.name),2,12,10,"",true,
                            "required","please enter text [a-zA-Z]{1,1} [A-z0-9]",
                            "^[a-zA-Z]{1,1}[a-zA-Z0-9]{0,}$")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp01.name),"TaskPanel") catch unreachable ;

    Panel.field.append(fld.newFieldUDigit(@tagName(fp01.posx),3,12,2,"",true,
                            "required","please enter Pos X 1...",
                            "")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp01.posx),"TaskPosx") catch unreachable ;

    Panel.field.append(fld.newFieldUDigit(@tagName(fp01.posy),4,12,3,"",true,
                            "required","please enter Pos y 1...",
                            "")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp01.posy),"TaskPosy") catch unreachable ;

    Panel.field.append(fld.newFieldUDigit(@tagName(fp01.lines),5,12,2,"",true,
                            "required","please enter Lines 1...",
                            "")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp01.lines),"TaskLines") catch unreachable ;

    Panel.field.append(fld.newFieldUDigit(@tagName(fp01.cols),6,12,3,"",true,
                            "required","please enter Cols   1...",
                            "")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp01.cols),"TaskCols") catch unreachable ;

    Panel.field.append(fld.newFieldFunc(@tagName(fp01.cadre),7,12,1,"",true,"FuncBorder",
                            "required","please choose the type of frame")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp01.cadre),"TaskCadre") catch unreachable ; 

    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.title),8,12,15,"",false,
                            "required","please enter text",
                            "")) catch unreachable ;

    Panel.lineh.append(lnh.newLine(@tagName(lp01.lnh1)     ,9,2,165,forms.LINE.line1) ) catch unreachable ;

    Panel.label.append(lbl.newLabel(@tagName(lp01.F_shw) ,11,9    ,"show"))     catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(lp01.F_chk) ,11,15 ,"check"))    catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(lp01.F_txt) ,11,22 ,"text") ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F1)     ,12,2    ,@tagName(fp01.F1)) ) catch unreachable ; 


    Panel.label.append(lbl.newLabel(@tagName(fp01.F2)     ,13,2    ,@tagName(fp01.F2)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F3)     ,14,2    ,@tagName(fp01.F3)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F4)     ,15,2    ,@tagName(fp01.F4)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F5)     ,16,2    ,@tagName(fp01.F5)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F6)     ,17,2    ,@tagName(fp01.F6)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F7)     ,18,2    ,@tagName(fp01.F7)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F8)     ,19,2    ,@tagName(fp01.F8)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F9)     ,20,2    ,@tagName(fp01.F9)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F10)    ,22,2    ,@tagName(fp01.F10)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F11)    ,23,2    ,@tagName(fp01.F11)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F12)    ,24,2    ,@tagName(fp01.F12)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F13)    ,25,2    ,@tagName(fp01.F13)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F14)    ,26,2    ,@tagName(fp01.F14)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F15)    ,27,2    ,@tagName(fp01.F15)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F16)    ,28,2    ,@tagName(fp01.F16)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F17)    ,29,2    ,@tagName(fp01.F17)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F18)    ,30,2    ,@tagName(fp01.F18)) ) catch unreachable ;
    

    Panel.label.append(lbl.newLabel(@tagName(fp01.F19)    ,31,2    ,@tagName(fp01.F19)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(lp01.F_shw2) ,11,50    ,"show"))     catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(lp01.F_shw2) ,11,55    ,"check"))    catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(lp01.F_shw2) ,11,62    ,"text") ) catch unreachable ;
    Panel.linev.append(lnv.newLine(@tagName(lp01.lnv1)    ,11,39,26,forms.LINE.line1) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F20)    ,12,42    ,@tagName(fp01.F20)) ) catch unreachable ;
    

    Panel.label.append(lbl.newLabel(@tagName(fp01.F21)    ,13,42    ,@tagName(fp01.F21)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F22)    ,14,42    ,@tagName(fp01.F22)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F23)    ,15,42    ,@tagName(fp01.F23)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F24)    ,16,42    ,@tagName(fp01.F24)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F25)    ,17,42    ,@tagName(fp01.F25)) ) catch unreachable ;
    

    Panel.label.append(lbl.newLabel(@tagName(fp01.F26)    ,18,42    ,@tagName(fp01.F26)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F27)    ,19,42    ,@tagName(fp01.F27)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F28)    ,20,42    ,@tagName(fp01.F28)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F29)    ,21,42    ,@tagName(fp01.F29)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F30)    ,23,42    ,@tagName(fp01.F30)) ) catch unreachable ;
    

    Panel.label.append(lbl.newLabel(@tagName(fp01.F31)    ,24,42    ,@tagName(fp01.F31)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F32)    ,25,42    ,@tagName(fp01.F32)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F33)    ,26,42    ,@tagName(fp01.F33)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F34)    ,27,42    ,@tagName(fp01.F34)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F35)    ,28,42    ,@tagName(fp01.F35)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.F36)    ,29,42    ,@tagName(fp01.F36)) ) catch unreachable ;

    
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F1)         ,12,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F1_shw)     ,12,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F1_chk)     ,12,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F1_txt) ,12,22,15,"",false,
                                        "required","please enter text fonction","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F2)         ,13,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F2_shw)     ,13,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F2_chk)     ,13,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F2_txt) ,13,22,15,"",false,
                                        "required","please enter text fonction","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F3)         ,14,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F3_shw)     ,14,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F3_chk)     ,14,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F3_txt) ,14,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F4)         ,15,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F4_shw)     ,15,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F4_chk)     ,15,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F4_txt) ,15,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F5)         ,16,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F5_shw)     ,16,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F5_chk)     ,16,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F5_txt) ,16,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F6)         ,17,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F6_shw)     ,17,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F6_chk)     ,17,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F6_txt) ,17,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F7)         ,18,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F7_shw)     ,18,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F7_chk)     ,18,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F7_txt) ,18,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F8)         ,19,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F8_shw)     ,19,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F8_chk)     ,19,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F8_txt) ,19,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F9)         ,20,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F9_shw)     ,20,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F9_chk)     ,20,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F9_txt) ,20,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F10)     ,22,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F10_shw) ,22,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F10_chk) ,22,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F10_txt) ,22,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F11)     ,23,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F11_shw) ,23,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F11_chk) ,23,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F11_txt) ,23,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F12)     ,24,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F12_shw) ,24,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F12_chk) ,24,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F12_txt) ,24,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F13)     ,25,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F13_shw) ,25,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F13_chk) ,25,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F13_txt) ,25,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;
    
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F14)     ,26,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F14_shw) ,26,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F14_chk) ,26,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F14_txt) ,26,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F15)     ,27,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F15_shw) ,27,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F15_chk) ,27,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F15_txt) ,27,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F16)     ,28,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F16_shw) ,28,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F16_chk) ,28,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F16_txt) ,28,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F17)     ,29,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F17_shw) ,29,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F17_chk) ,29,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F17_txt) ,29,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F18)     ,30,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F18_shw) ,30,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F18_chk) ,30,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F18_txt) ,30,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;
    
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F19)     ,31,6,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F19_shw) ,31,10,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F19_chk) ,31,17,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F19_txt) ,31,22,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

                                    

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F20)     ,12,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F20_shw) ,12,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F20_chk) ,12,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F20_txt) ,12,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F21)     ,13,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F21_shw) ,13,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F21_chk) ,13,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F21_txt) ,13,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F22)     ,14,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F22_shw) ,14,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F22_chk) ,14,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F22_txt) ,14,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F23)     ,15,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F23_shw) ,15,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F23_chk) ,15,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F23_txt) ,15,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F24)     ,16,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F24_shw) ,16,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F24_chk) ,16,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F24_txt) ,16,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;


    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F25)     ,17,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F25_shw) ,17,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F25_chk) ,17,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F25_txt) ,17,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F26)     ,18,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F26_shw) ,18,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F26_chk) ,18,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F26_txt) ,18,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F27)     ,19,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F27_shw) ,19,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F27_chk) ,19,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F27_txt) ,19,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F28)     ,20,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F28_shw) ,20,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F28_chk) ,20,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F28_txt) ,20,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F29)     ,21,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F29_shw) ,21,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F29_chk) ,21,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F29_txt) ,21,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;


                                    

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F30)     ,23,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F30_shw) ,23,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F30_chk) ,23,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F30_txt) ,23,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F31)     ,24,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F31_shw) ,24,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F31_chk) ,24,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F31_txt) ,24,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F32)     ,25,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F32_shw) ,25,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F32_chk) ,25,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F32_txt) ,25,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F33)     ,26,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F33_shw) ,26,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F33_chk) ,26,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F33_txt) ,26,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F34)     ,27,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F34_shw) ,27,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F34_chk) ,27,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F34_txt) ,27,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;


    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F35)     ,28,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F35_shw) ,28,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F35_chk) ,28,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F35_txt) ,28,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F36)     ,29,46,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F36_shw) ,29,51,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.F36_chk) ,29,57,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.F36_txt) ,29,62,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;


                                    

    Panel.linev.append(lnv.newLine(@tagName(lp01.lnv2)     ,11,79,26,forms.LINE.line1) ) catch unreachable ;

    Panel.label.append(lbl.newLabel(@tagName(lp01.ctrl_shw) ,11,90    ,"show"))    catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(lp01.ctrl_chk) ,11,96    ,"check"))    catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(lp01.ctrl_txt) ,11,103    ,"text") )    catch unreachable ;

    Panel.label.append(lbl.newLabel(@tagName(fp01.altA) ,12,82 ,@tagName(fp01.altA)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altB) ,13,82 ,@tagName(fp01.altB)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altC) ,14,82 ,@tagName(fp01.altC)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altD) ,15,82 ,@tagName(fp01.altD)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altE) ,16,82 ,@tagName(fp01.altE)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altF) ,17,82 ,@tagName(fp01.altF)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altG) ,18,82 ,@tagName(fp01.altG)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altH) ,19,82 ,@tagName(fp01.altH)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altI) ,20,82 ,@tagName(fp01.altI)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altJ) ,21,82 ,@tagName(fp01.altJ)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altK) ,22,82 ,@tagName(fp01.altK)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altL) ,23,82 ,@tagName(fp01.altL)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altM) ,24,82 ,@tagName(fp01.altM)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altN) ,25,82 ,@tagName(fp01.altN)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altO) ,26,82 ,@tagName(fp01.altO)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altP) ,27,82 ,@tagName(fp01.altP)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altQ) ,28,82 ,@tagName(fp01.altQ)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altR) ,29,82 ,@tagName(fp01.altR)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altS) ,30,82 ,@tagName(fp01.altS)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altT) ,31,82 ,@tagName(fp01.altT)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altU) ,32,82 ,@tagName(fp01.altU)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altV) ,33,82 ,@tagName(fp01.altV)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altW) ,34,82 ,@tagName(fp01.altW)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altX) ,35,82 ,@tagName(fp01.altX)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altY) ,36,82 ,@tagName(fp01.altY)) ) catch unreachable ;


    Panel.label.append(lbl.newLabel(@tagName(fp01.altZ) ,37,82 ,@tagName(fp01.altZ)) ) catch unreachable ;



    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altA)        ,12,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altA_shw)    ,12,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altA_chk)    ,12,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altA_txt) ,12,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;


    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altB)        ,13,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altB_shw)    ,13,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altB_chk)    ,13,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altB_txt) ,13,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altC)        ,14,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altC_shw)    ,14,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altC_chk)    ,14,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altC_txt) ,14,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altD)        ,15,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altD_shw)    ,15,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altD_chk)    ,15,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altD_txt) ,15,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;


    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altE)         ,16,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altE_shw)     ,16,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altE_chk)     ,16,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altE_txt) ,16,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altF)        ,17,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altF_shw)    ,17,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altF_chk)    ,17,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altF_txt) ,17,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altG)        ,18,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altG_shw)    ,18,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altG_chk)    ,18,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altG_txt) ,18,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altH)        ,19,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altH_shw)    ,19,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altH_chk)    ,19,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altH_txt) ,19,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altI)        ,20,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altI_shw)    ,20,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altI_chk)    ,20,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altI_txt) ,20,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altJ)        ,21,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altJ_shw)    ,21,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altJ_chk)    ,21,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altJ_txt) ,21,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altK)        ,22,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altK_shw)    ,22,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altK_chk)    ,22,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altK_txt) ,22,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altL)        ,23,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altL_shw)    ,23,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altL_chk)    ,23,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altL_txt) ,23,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altM)        ,24,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altM_shw)    ,24,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altM_chk)    ,24,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altM_txt) ,24,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altN)        ,25,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altN_shw)    ,25,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altN_chk)    ,25,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altN_txt) ,25,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altO)         ,26,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altO_shw)     ,26,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altO_chk)     ,26,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altO_txt) ,26,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altP)        ,27,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altP_shw)    ,27,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altP_chk)    ,27,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altP_txt) ,27,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altQ)        ,28,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altQ_shw)    ,28,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altQ_chk)    ,28,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altQ_txt) ,28,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altR)        ,29,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altR_shw)    ,29,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altR_chk)    ,29,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altR_txt) ,29,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altS)        ,30,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altS_shw)    ,30,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altS_chk)    ,30,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altS_txt) ,30,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altT)        ,31,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altT_shw)    ,31,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altT_chk)    ,31,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altT_txt) ,31,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altU)        ,32,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altU_shw)    ,32,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altU_chk)    ,32,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altU_txt) ,32,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altV)         ,33,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altV_shw)     ,33,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altV_chk)     ,33,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altV_txt) ,33,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altW)        ,34,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altW_shw)    ,34,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altW_chk)    ,34,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altW_txt) ,34,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altX)        ,35,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altX_shw)    ,35,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altX_chk)    ,35,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altX_txt) ,35,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altY)        ,36,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altY_shw)    ,36,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altY_chk)    ,36,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altY_txt) ,36,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altZ)        ,37,87,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altZ_shw)    ,37,91,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.altZ_chk)    ,37,98,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.altZ_txt) ,37,103,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;


    Panel.linev.append(lnv.newLine(@tagName(lp01.lnv3)     ,11,119,26,forms.LINE.line1) ) catch unreachable ;

    Panel.label.append(lbl.newLabel(@tagName(lp01.ctrl_shw) ,11,131    ,"show"))     catch unreachable ; 
    Panel.label.append(lbl.newLabel(@tagName(lp01.ctrl_chk) ,11,137    ,"check"))    catch unreachable ; 
    Panel.label.append(lbl.newLabel(@tagName(lp01.ctrl_txt) ,11,144    ,"text") ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlA) ,12,122 ,@tagName(fp01.ctrlA)) ) catch unreachable ; 
    
    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlB) ,13,122 ,@tagName(fp01.ctrlB)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlC) ,14,122 ,@tagName(fp01.ctrlC)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlD) ,15,122 ,@tagName(fp01.ctrlD)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlE) ,16,122 ,@tagName(fp01.ctrlE)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlF) ,17,122 ,@tagName(fp01.ctrlF)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlG) ,18,122 ,@tagName(fp01.ctrlG)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlH) ,19,122 ,@tagName(fp01.ctrlH)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlI) ,20,122 ,@tagName(fp01.ctrlI)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlJ) ,21,122 ,@tagName(fp01.ctrlJ)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlK) ,22,122 ,@tagName(fp01.ctrlK)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlL) ,23,122 ,@tagName(fp01.ctrlL)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlM) ,24,122 ,@tagName(fp01.ctrlM)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlN) ,25,122 ,@tagName(fp01.ctrlN)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlO) ,26,122 ,@tagName(fp01.ctrlO)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlP) ,27,122 ,@tagName(fp01.ctrlP)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlQ) ,28,122 ,@tagName(fp01.ctrlQ)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlR) ,29,122 ,@tagName(fp01.ctrlR)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlS) ,30,122 ,@tagName(fp01.ctrlS)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlT) ,31,122 ,@tagName(fp01.ctrlT)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlU) ,32,122 ,@tagName(fp01.ctrlU)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlV) ,33,122 ,@tagName(fp01.ctrlV)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlW) ,34,122 ,@tagName(fp01.ctrlW)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlX) ,35,122 ,@tagName(fp01.ctrlX)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlY) ,36,122 ,@tagName(fp01.ctrlY)) ) catch unreachable ; 

    Panel.label.append(lbl.newLabel(@tagName(fp01.ctrlZ) ,37,122 ,@tagName(fp01.ctrlZ)) ) catch unreachable ; 



    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlA)        ,12,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlA_shw)    ,12,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlA_chk)    ,12,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlA_txt) ,12,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlB)        ,13,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlB_shw)    ,13,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlB_chk)    ,13,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlB_txt) ,13,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlC)        ,14,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlC_shw)    ,14,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlC_chk)    ,14,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlC_txt) ,14,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlD)        ,15,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlD_shw)    ,15,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlD_chk)    ,15,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlD_txt) ,15,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlE)        ,16,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlE_shw)    ,16,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlE_chk)    ,16,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlE_txt) ,16,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlF)        ,17,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlF_shw)    ,17,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlF_chk)    ,17,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlF_txt) ,17,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlG)         ,18,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlG_shw)     ,18,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlG_chk)     ,18,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlG_txt) ,18,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlH)        ,19,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlH_shw)    ,19,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlH_chk)    ,19,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlH_txt) ,19,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlI)        ,20,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlI_shw)    ,20,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlI_chk)    ,20,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlI_txt) ,20,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlJ)        ,21,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlJ_shw)    ,21,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlJ_chk)    ,21,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlJ_txt) ,21,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlK)        ,22,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlK_shw)    ,22,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlK_chk)    ,22,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlK_txt) ,22,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlL)        ,23,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlL_shw)    ,23,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlL_chk)    ,23,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlL_txt) ,23,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlM)         ,24,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlM_shw)     ,24,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlM_chk)     ,24,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlM_txt) ,24,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlN)         ,25,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlN_shw)     ,25,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlN_chk)     ,25,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlN_txt) ,25,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlO)         ,26,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlO_shw)     ,26,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlO_chk)     ,26,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlO_txt) ,26,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlP)         ,27,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlP_shw)     ,27,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlP_chk)     ,27,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlP_txt) ,27,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlQ)         ,28,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlQ_shw)     ,28,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlQ_chk)     ,28,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlQ_txt) ,28,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlR)         ,29,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlR_shw)     ,29,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlR_chk)     ,29,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlR_txt) ,29,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlS)         ,30,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlS_shw)     ,30,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlS_chk)     ,30,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlS_txt) ,30,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlT)         ,31,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlT_shw)     ,31,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlT_chk)     ,31,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlT_txt) ,31,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlU)         ,32,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlU_shw)     ,32,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlU_chk)     ,32,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlU_txt) ,32,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlV)         ,33,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlV_shw)     ,33,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlV_chk)     ,33,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlV_txt) ,33,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlW)         ,34,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlW_shw)     ,34,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlW_chk)     ,34,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlW_txt) ,34,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlX)         ,35,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlX_shw)     ,35,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlX_chk)     ,35,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlX_txt) ,35,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlY)         ,36,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlY_shw)     ,36,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlY_chk)     ,36,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlY_txt) ,36,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;

    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlZ)         ,37,128,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlZ_shw)     ,37,132,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldSwitch(@tagName(fp01.ctrlZ_chk)     ,37,139,false,"","")) catch unreachable ;
    Panel.field.append(fld.newFieldTextFull(@tagName(fp01.ctrlZ_txt) ,37,144,15,"",false,
                                        "required","please enter text fonction ","")) catch unreachable ;






    return Panel;
}



//=================================================
// description Function
// choix work panel
pub fn qryPanel(vpnl: *std.ArrayList(pnl.PANEL)) usize {
        const cellPos: usize = 0;
        var Gkey: grd.GridSelect = undefined;
    
        const Xcombo : *grd.GRID =    grd.newGridC(
                "qryPanel",
                12,
                1,
                20,
                grd.gridStyle,
                grd.CADRE.line1,
        );

        defer Gkey.Buf.deinit();
        defer grd.freeGrid(Xcombo);
        defer grd.allocatorGrid.destroy(Xcombo);
    
        grd.newCell(Xcombo,"ID", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
        grd.newCell(Xcombo,"Name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
        grd.newCell(Xcombo,"Title", 15, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
        grd.setHeaders(Xcombo);


        for (vpnl.items , 0..) |p , idx| {
                grd.addRows(Xcombo, &.{ utl.usizeToStr(idx), p.name, p.frame.title });
        }

        // It seems unlikely that you will go over 50 panel
        grd.addRows(Xcombo,    &.{"888", "Add", "Panel"}) ;

    
        while (true) {
                Gkey = grd.ioCombo(Xcombo, cellPos);

                if (Gkey.Key == kbd.enter) {
                    return    utl.strToUsize(Gkey.Buf.items[0]);
                }


                if (Gkey.Key == kbd.esc) {
                        return 999;
                }
        }

}


var callFunc: FuncEnum = undefined;
//=================================================
// description Function
// choix Cadre
fn FuncBorder( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {

    var pos:usize = 1;

    var mCadre = mnu.newMenu(
                            "cadre",                // name
                            8, 12,                    // posx, posy
                            mnu.CADRE.line1,        // type line fram
                            mnu.MNUVH.vertical,        // type menu vertical / horizontal
                            &.{                        // item
                            "Noline",
                            "Line 1",
                            "Line 2",
                            });
    var nitem    :usize = 0;
    if (std.mem.eql(u8, vfld.text, "0")) pos = 0;
    if (std.mem.eql(u8, vfld.text, "1")) pos = 1;
    if (std.mem.eql(u8, vfld.text, "2")) pos = 2;
    while (true) {
        nitem    = mnu.ioMenu(mCadre,pos);
        if (nitem != 9999) break;
    }

    vfld.text = std.fmt.allocPrint(forms.allocatorForms,"{d}",.{nitem}) catch unreachable; 
    pnl.rstPanel(mnu.MENU,&mCadre,vpnl);
}

//=================================================
// description Function
/// run emun Function ex: combo
pub const FuncEnum = enum {
    FuncBorder,
    none,

    pub fn run(self: FuncEnum, vpnl : *pnl.PANEL, vfld: *fld.FIELD) void    {
        switch (self) {
                .FuncBorder => FuncBorder(vpnl,vfld),
                else => dsperr.errorForms(vpnl,    ErrMain.main_run_EnumFunc_invalide),
        }
    }

    fn searchFn ( vtext: [] const u8 ) FuncEnum {
        inline for (@typeInfo(FuncEnum).@"enum".fields) |f| { 
                if ( std.mem.eql(u8, f.name , vtext) ) return @as(FuncEnum,@enumFromInt(f.value));
            }
            return FuncEnum.none; 
    }
};


var callTask: TaskEnum = undefined;
//=================================================
// description Function
// test exist Name for add or change name

fn TaskPosx( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {
    const termSize = term.getSize();
    const posx =     utl.strToUsize(vfld.text);
    
    if (termSize.height < posx or posx    == 0 ) {
                const allocator = std.heap.page_allocator;
                const msg = std.fmt.allocPrint(allocator,"{d} Position X is out of bounds",.{termSize.height})
                    catch unreachable;
        defer allocator.free(msg);
        term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text,pnl.FldErr);
        pnl.msgErr(vpnl, msg);
        vpnl.keyField = kbd.task;
    }
}

fn TaskPosy( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {
    const termSize = term.getSize();
    const posy    =    utl.strToUsize(vfld.text);
    
    if (termSize.width < posy or posy == 0 ) {
                const allocator = std.heap.page_allocator;
                const msg = std.fmt.allocPrint(allocator,"{d} Position Y is out of bounds",.{termSize.width})
                    catch unreachable;
        defer allocator.free(msg);
        term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text,pnl.FldErr);
        pnl.msgErr(vpnl, msg);
        vpnl.keyField = kbd.task;
    }
}

fn TaskLines( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {
        const termSize = term.getSize() ;
        const lines =    utl.strToUsize(vfld.text);
        const posx    =    utl.strToUsize(fld.getText(vpnl,@intFromEnum(fp01.posx)) catch unreachable) ;
        
        if (termSize.height < lines or lines == 0 or termSize.height < lines + posx - 1 ) {
            const allocator = std.heap.page_allocator;
            const msg = std.fmt.allocPrint(
            allocator,"{d} The number of rows is out of range",
            .{termSize.height}) catch unreachable;
            defer allocator.free(msg);
            term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
            term.writeStyled(vfld.text,pnl.FldErr);
            pnl.msgErr(vpnl, msg);
            vpnl.keyField = kbd.task;
        }
}

fn TaskCols( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {
    const termSize = term.getSize();
    const cols    =    utl.strToUsize(vfld.text);
    const posy    =    utl.strToUsize(fld.getText(vpnl,@intFromEnum(fp01.posy)) catch unreachable);

    if (termSize.width < cols or cols == 0 or termSize.width < cols + posy - 1 ) {
        const allocator = std.heap.page_allocator;
        const msg = std.fmt.allocPrint(
            allocator,"{d} The number of columns is out of range",
            .{termSize.width }) catch unreachable;
        defer allocator.free(msg);
        term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text,pnl.FldErr);
        pnl.msgErr(vpnl, msg);
        vpnl.keyField = kbd.task;
    }
}


fn TaskCadre( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {
    const termSize = term.getSize();
    const cadre =    utl.strToUsize(vfld.text);
    
    if (termSize.width < cadre or cadre == 0 ) {
        const allocator = std.heap.page_allocator;
        const msg = std.fmt.allocPrint(allocator,
            "{d} The number of Lines Cadre is out of range",.{termSize.width }) catch unreachable;
        defer allocator.free(msg);
        term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text,pnl.FldErr);
        pnl.msgErr(vpnl, msg);
        vpnl.keyField = kbd.task;
        }
}



fn TaskPanel(VPANEL: *std.ArrayList(pnl.PANEL), vpnl: *pnl.PANEL , vfld: *fld.FIELD, panelNum: usize) void {

    for (VPANEL.items , 0..) |f, idx | {
        if (std.mem.eql(u8, f.name, vfld.text) and ( idx == panelNum ) ) {
            return ;
        }    
        if (std.mem.eql(u8, f.name, vfld.text) and ( 999 == panelNum ) ) {
            pnl.msgErr(vpnl, "Already existing invalide");
            vpnl.keyField = kbd.task; 
            return ;
        }
    }
}


fn TaskF9(    VPANEL: *std.ArrayList(pnl.PANEL), vpnl:*pnl.PANEL , vfld: *fld.FIELD, panelNum: usize) void {
    vpnl.keyField = kbd.none;
    
    for (VPANEL.items , 0..) |f , idx| {
        if (std.mem.eql(u8, f.name, vfld.text) and    888 == panelNum    or
            std.mem.eql(u8, f.name, vfld.text)    and    idx == panelNum    ) {
            vpnl.keyField = kbd.task;
            vpnl.idxfld = @intFromEnum(fp01.name);
            const allocator = std.heap.page_allocator;
            const msg = std.fmt.allocPrint(allocator,"Name: {s} lready existing invalide",.{vfld.text})
                        catch unreachable;
            defer allocator.free(msg);
            pnl.msgErr(vpnl,msg);
            return ;
        } 
        if (std.mem.eql(u8, f.name, vfld.text) and ( 999 == panelNum) ) return ;

    }
}


fn TaskF11( VPANEL: *std.ArrayList(pnl.PANEL) ,vpnl:*pnl.PANEL , vfld: *fld.FIELD, panelNum: usize) void {
    vpnl.keyField = kbd.none;

    for (VPANEL.items ,0..) |f ,idx | {
        if (std.mem.eql(u8, f.name, vfld.text) and ( idx != panelNum)     ) {
            vpnl.keyField = kbd.task;
            vpnl.idxfld = @intFromEnum(fp01.name);
            const allocator = std.heap.page_allocator;
            const msg = std.fmt.allocPrint(allocator,"{s} lready existing invalide",.{vfld.text})
                        catch unreachable;
            defer allocator.free(msg);
            pnl.msgErr(vpnl,msg);
            return ;
        } 
        if (std.mem.eql(u8, f.name, vfld.text) and ( 999 == panelNum) ) return ;

    }
}

//=================================================
// description Function
/// run emun Function ex: combo
pub const TaskEnum = enum {
    TaskPosx,
    TaskPosy,
    TaskLines,
    TaskCols,
    TaskCadre,
    TaskPanel,
    TaskF9,
    TaskF11,
    none,

    pub fn run(self: TaskEnum, VPANEL: *std.ArrayList(pnl.PANEL),
                                vpnl : *pnl.PANEL,
                                vfld: *fld.FIELD,
                                panelNum : usize) void    {
                switch (self) {
                .TaskPosx    => TaskPosx(vpnl,vfld),
                .TaskPosy    => TaskPosy(vpnl,vfld),
                .TaskLines    => TaskLines(vpnl,vfld),
                .TaskCols    => TaskCols(vpnl,vfld),
                .TaskCadre    => TaskCadre(vpnl,vfld),

                .TaskPanel => TaskPanel(VPANEL,vpnl,vfld, panelNum),

                .TaskF9    => TaskF9(VPANEL,vpnl,vfld,panelNum),
                .TaskF11 => TaskF11(VPANEL,vpnl,vfld, panelNum),

                else => dsperr.errorForms(vpnl,    ErrMain.main_run_EnumTask_invalide),
                }
    }
    fn searchFn ( vtext: [] const u8 ) TaskEnum {
        inline for (@typeInfo(TaskEnum).@"enum".fields) |f| { 
                if ( std.mem.eql(u8, f.name , vtext) ) return @as(TaskEnum,@enumFromInt(f.value));
        }
        return TaskEnum.none;
    }
};





//pub fn main() !void {
pub fn fnPanel(XPANEL: *std.ArrayList(pnl.PANEL)) void { 
    

    term.cls();

    var numPanel : usize = undefined ;

    numPanel = qryPanel(XPANEL);

    if (numPanel == 999) return;

    var pFmt01 = Panel_Fmt01();

    var NPANEL = std.ArrayList(pnl.PANEL).init(forms.allocatorForms);
    NPANEL.clearRetainingCapacity();

    for (XPANEL.items) |p| {
        NPANEL.append( p) catch |err| { @panic(@errorName(err));};
    }


    if (numPanel < 888 ) {
        loadPanel(&NPANEL.items[numPanel], pFmt01);
    }
    else {
         const termSize = term.getSize();

         fld.setText(pFmt01,@intFromEnum(fp01.lines),utl.usizeToStr(termSize.height))
            catch unreachable ;
         fld.setText(pFmt01,@intFromEnum(fp01.cols),utl.usizeToStr(termSize.width))
            catch unreachable ;
            
    }
    fld.MouseDsp = true ; // active display cursor x/y mouse
    
    
    var Tkey : term.Keyboard = undefined ; // defines the receiving structure of the keyboard


    while (true) {
        //Tkey = kbd.getKEY();
        Tkey.Key = pnl.ioPanel(pFmt01);

        
        switch (Tkey.Key) {
            // call function combo
            .func => {
                callFunc = FuncEnum.searchFn(pFmt01.field.items[pFmt01.idxfld].procfunc); 
                callFunc.run(pFmt01, &pFmt01.field.items[pFmt01.idxfld]) ;
            },

            // call proc contrôl chek value
            .task => {
                callTask = TaskEnum.searchFn(pFmt01.field.items[pFmt01.idxfld].proctask); 
                callTask.run(&NPANEL, pFmt01, &pFmt01.field.items[pFmt01.idxfld], numPanel) ;
            },
            
            // test display
            .F2 => {
                if (NPANEL.items.len == 0 ) { dsperr.errorForms(pFmt01, ErrMain.main_NPANEL_invalide); continue;}
                pnl.initMatrix(&NPANEL.items[numPanel]);
                pnl.printPanel(&NPANEL.items[numPanel]);
                _= kbd.getKEY();
                NPANEL.items[numPanel].buf.clearAndFree();
                NPANEL.items[numPanel].buf.deinit();
                pnl.printPanel(pFmt01);

            },

            // choix panel
            .F6 => {
                numPanel = qryPanel(&NPANEL);
                if (numPanel == 999) {
                    pnl.freePanel(pFmt01);
                    NPANEL.clearAndFree();
                    NPANEL.deinit();
                    return;
                } 
                if (numPanel < 888 ) {
                    pnl.clearPanel(pFmt01);
                    loadPanel(&NPANEL.items[numPanel], pFmt01);
                }
            },

            // creat Panel
            .F9 => {

                for (pFmt01.field.items , 0..) |f , idx| {
                    if (f.proctask.len > 0) {
                        pFmt01.idxfld = idx ;
                        pFmt01.keyField = kbd.none;
                        if (idx == @intFromEnum(fp01.name))
                            callTask = TaskEnum.searchFn("TaskF9")
                        else callTask = TaskEnum.searchFn(f.proctask);
                        
                        callTask.run(&NPANEL, pFmt01, &pFmt01.field.items[pFmt01.idxfld], numPanel);
                        if (pFmt01.keyField == kbd.task) break;
                    }
                }
                if (pFmt01.keyField == kbd.task) continue;
                pFmt01.idxfld = 9999;
                addPanel(pFmt01,&NPANEL , XPANEL);
                pnl.msgErr(pFmt01,"You are in creation correct F9 OK");
                pnl.clearPanel(pFmt01);
                numPanel = NPANEL.items.len - 1;// last panel
                utl.deinitUtl();
                loadPanel(&XPANEL.items[numPanel], pFmt01);
            },

            // update Panel
            .F11 => {

                if ( numPanel < 888 ) {
                    for (pFmt01.field.items , 0..) |f, idx| {
                        if (f.proctask.len > 0) {
                            pFmt01.idxfld = idx ;
                            pFmt01.keyField = kbd.none;
                            if (idx == @intFromEnum(fp01.name))    callTask = TaskEnum.searchFn("TaskF11")
                            else callTask = TaskEnum.searchFn(f.proctask);
                            
                            callTask.run(&NPANEL, pFmt01, &pFmt01.field.items[pFmt01.idxfld],numPanel);
                            if (pFmt01.keyField == kbd.task) break;
                        }
                    }
                    if (pFmt01.keyField == kbd.task) continue;
                    pFmt01.idxfld =9999;
                    updPanel(pFmt01, &NPANEL.items[numPanel] , &XPANEL.items[numPanel] );
                    pnl.msgErr(pFmt01,"The update is correct F11 OK");
                    pnl.clearPanel(pFmt01);
                    utl.deinitUtl();
                    loadPanel(&NPANEL.items[numPanel], pFmt01);
                } 
                else    pnl.msgErr(pFmt01,"You are in creation mode Bad F11");
            },

            // exit module panel 
            .F12 => {
                pnl.freePanel(pFmt01);
                forms.allocatorForms.destroy(pFmt01);
                NPANEL.clearAndFree();
                NPANEL.deinit();
                utl.deinitUtl();

                return ; 
            },

            else => {}
        }
    }

}

/// procédure -------------------------------


fn loadPanel(src: *pnl.PANEL , dst:*pnl.PANEL ) void {

        // name
        fld.setText(dst,@intFromEnum(fp01.name), src.name)
        catch |err| { @panic(@errorName(err));};
        // posx
        fld.setText(dst,@intFromEnum(fp01.posx),
            utl.usizeToStr(src.posx) ) 
            catch |err| { @panic(@errorName(err));};
        // posy
        fld.setText(dst,@intFromEnum(fp01.posy),
            utl.usizeToStr(src.posy) ) 
            catch |err| { @panic(@errorName(err));};
        // lines
        fld.setText(dst,@intFromEnum(fp01.lines),
            utl.usizeToStr(src.lines) ) 
            catch |err| { @panic(@errorName(err));};
        // cols
        fld.setText(dst,@intFromEnum(fp01.cols),
            utl.usizeToStr(src.cols) ) 
            catch |err| { @panic(@errorName(err));};
        // cadre
        fld.setText(dst,@intFromEnum(fp01.cadre),
            utl.usizeToStr(@intFromEnum(src.frame.cadre)) ) 
            catch |err| { @panic(@errorName(err));};
        // title
        fld.setText(dst,@intFromEnum(fp01.title), src.frame.title) 
            catch |err| { @panic(@errorName(err));};


        var fxx:    usize = 0;
        var show:    usize = 0;
        var check:    usize = 0 ;
        var title:    usize = 0 ;
        var buf: [] const u8 = "";
        for (src.button.items) |b| {
            if (@intFromEnum(b.key) >= @intFromEnum(kbd.F1) and @intFromEnum(b.key) <= @intFromEnum(kbd.F36) ) {
                                                                fxx = @intFromEnum(b.key) ;
                                                                if ( 1 == fxx) fxx += 6 
                                                                else fxx = 6 +    (fxx * 4) - 3 ;
                                                                buf = @tagName(@as(fp01,@enumFromInt(fxx))) ;
            }

            if (@intFromEnum(b.key) >= @intFromEnum(kbd.altA) and @intFromEnum(b.key) <= @intFromEnum(kbd.altZ) ) {
                                                                fxx = @intFromEnum(b.key) ;
                                                                if ( 25 == fxx) fxx = 103 
                                                                else fxx = 102 + ( (fxx - 24)    * 4) - 3 ;
                                                                buf = @tagName(@as(fp01,@enumFromInt(fxx))) ;
            }

            
            if (@intFromEnum(b.key) >= @intFromEnum(kbd.ctrlA) and @intFromEnum(b.key) <= @intFromEnum(kbd.ctrlZ) ){
                                                                fxx = @intFromEnum(b.key);
                                                                if ( 51 == fxx) fxx = 207 
                                                                else fxx = 206 + ( (fxx - 50) * 4) - 3 ;
                                                                buf = @tagName(@as(fp01,@enumFromInt(fxx))) ;
            }

            fxx = fld.getIndex(dst, buf) catch |err| { @panic(@errorName(err));};
            show  = fxx + 1;
            check = fxx + 2 ;
            title = fxx + 3 ;

            fld.setSwitch(dst , fxx         , true)        catch |err| { @panic(@errorName(err));};
            fld.setSwitch(dst , show    , b.show)        catch |err| { @panic(@errorName(err));};
            fld.setSwitch(dst , check     , b.check)        catch |err| { @panic(@errorName(err));};
            fld.setText(dst    , title , b.title)            catch |err| { @panic(@errorName(err));};
        }

}





fn addPanel( src: *pnl.PANEL, vNPANEL :    *std.ArrayList(pnl.PANEL),    vXPANEL: *std.ArrayList(pnl.PANEL) ) void {

    var panel = pnl.initPanel(src.field.items[@intFromEnum(fp01.name)].text,
                                        utl.strToUsize(src.field.items[@intFromEnum(fp01.posx)].text),
                                        utl.strToUsize(src.field.items[@intFromEnum(fp01.posy)].text),
                                        utl.strToUsize(src.field.items[@intFromEnum(fp01.lines)].text),
                                        utl.strToUsize(src.field.items[@intFromEnum(fp01.cols)].text),
                                        @as(forms.CADRE,@enumFromInt(
                                                utl.strToUsize(src.field.items[@intFromEnum(fp01.cadre)].text))),
                                        src.field.items[@intFromEnum(fp01.title)].text);



    var fxx : usize = @intFromEnum(fp01.F1);
    var kxx     : usize =0 ;

    var show    : usize =0 ;
    var check : usize =0 ;
    var title : usize =0 ;

    while ( fxx <= @intFromEnum(fp01.F36)) :( fxx += 1 ) {
        kxx     += 1;
        show    = fxx + 1;    // pos fld show
        check = fxx + 2;    // pos fld show
        title = fxx + 3;    // pos fld show
        fxx = title ; 

        if ( src.field.items[show].zwitch or src.field.items[check].zwitch ) {
            panel.button.append(btn.newButton(
                                            kbd.toEnum(@tagName(@as(kbd,@enumFromInt(kxx)))),    // function
                                            src.field.items[show].zwitch,    // show
                                            src.field.items[check].zwitch,    // check field
                                            src.field.items[title].text,    // title 
                                            )
                                        ) catch unreachable ;
        }
    }

    fxx = @intFromEnum(fp01.altA);
    kxx     = @intFromEnum(kbd.F36) ;
    show    = 0 ;
    check = 0 ;
    title = 0 ;

    while ( fxx <= @intFromEnum(fp01.altZ)) :( fxx += 1 ) {
        kxx     += 1;
        show    = fxx + 1;    // pos fld show
        check = fxx + 2;    // pos fld show
        title = fxx + 3;    // pos fld show
        fxx = title ;
        if ( src.field.items[show].zwitch or src.field.items[check].zwitch ) {
            panel.button.append(btn.newButton(
                                            kbd.toEnum(@tagName(@as(kbd,@enumFromInt(kxx)))),    // function
                                            src.field.items[show].zwitch,    // show
                                            src.field.items[check].zwitch,    // check field
                                            src.field.items[title].text,    // title 
                                            )
                                        ) catch unreachable ;
        }
    }



    fxx = @intFromEnum(fp01.ctrlA);
    kxx     = @intFromEnum(kbd.altZ) ;

    show    = 0 ;
    check = 0 ;
    title = 0 ;

    while ( fxx <= @intFromEnum(fp01.ctrlZ)) :( fxx += 1 ) {
        kxx     += 1;
        show    = fxx + 1;    // pos fld show
        check = fxx + 2;    // pos fld show
        title = fxx + 3;    // pos fld show
        fxx = title ;
        if ( src.field.items[show].zwitch or src.field.items[check].zwitch ) {

            panel.button.append(btn.newButton(
                                            kbd.toEnum(@tagName(@as(kbd,@enumFromInt(kxx)))),    // function
                                            src.field.items[show].zwitch,    // show
                                            src.field.items[check].zwitch,    // check field
                                            src.field.items[title].text,    // title 
                                            )
                                        ) catch unreachable ;
        }
    }
    
    panel.buf.clearAndFree();

    vNPANEL.append(panel) catch unreachable;

    vXPANEL.append(panel) catch unreachable;

}

fn updPanel( src: *pnl.PANEL, vNPANEL: *pnl.PANEL, vXPANEL: *pnl.PANEL )    void {
    
    var panel : *pnl.PANEL = pnl.newPanelC(src.field.items[@intFromEnum(fp01.name)].text,
                                        utl.strToUsize(src.field.items[@intFromEnum(fp01.posx)].text),
                                        utl.strToUsize(src.field.items[@intFromEnum(fp01.posy)].text),
                                        utl.strToUsize(src.field.items[@intFromEnum(fp01.lines)].text),
                                        utl.strToUsize(src.field.items[@intFromEnum(fp01.cols)].text),
                                        @as(forms.CADRE,@enumFromInt(
                                                utl.strToUsize(src.field.items[@intFromEnum(fp01.cadre)].text))),
                                        src.field.items[@intFromEnum(fp01.title)].text);

    defer forms.allocatorForms.destroy(panel);

    var fxx : usize = @intFromEnum(fp01.F1);
    var kxx     : usize =0 ;

    var show    : usize =0 ;
    var check : usize =0 ;
    var title : usize =0 ;

    while ( fxx <= @intFromEnum(fp01.F36)) :( fxx += 1 ) {
        kxx     += 1;
        show    = fxx + 1;    // pos fld show
        check = fxx + 2;    // pos fld show
        title = fxx + 3;    // pos fld show

        fxx = title ; 

        if ( src.field.items[show].zwitch or src.field.items[check].zwitch ) {
            panel.button.append(btn.newButton(
                                            kbd.toEnum(@tagName(@as(kbd,@enumFromInt(kxx)))),    // function
                                            src.field.items[show].zwitch,    // show
                                            src.field.items[check].zwitch,    // check field
                                            src.field.items[title].text,    // title 
                                                )
                                        ) catch |err| { @panic(@errorName(err));};
        }
    }

    fxx = @intFromEnum(fp01.altA);
    kxx     = @intFromEnum(kbd.F36) ;
    show    = 0 ;
    check = 0 ;
    title = 0 ;

    while ( fxx <= @intFromEnum(fp01.altZ)) :( fxx += 1 ) {
        kxx     += 1;
        show  = fxx + 1;    // pos fld show
        check = fxx + 2;    // pos fld show
        title = fxx + 3;    // pos fld show
        fxx = title ;
        if ( src.field.items[show].zwitch or src.field.items[check].zwitch ) {
            panel.button.append(btn.newButton(
                                            kbd.toEnum(@tagName(@as(kbd,@enumFromInt(kxx)))),    // function
                                            src.field.items[show].zwitch,    // show
                                            src.field.items[check].zwitch,    // check field
                                            src.field.items[title].text,    // title 
                                                )
                                        ) catch |err| { @panic(@errorName(err));};
        }
    }


    fxx = @intFromEnum(fp01.ctrlA);
    kxx     = @intFromEnum(kbd.altZ) ;

    show  = 0 ;
    check = 0 ;
    title = 0 ;

    while ( fxx <= @intFromEnum(fp01.ctrlZ)) :( fxx += 1 ) {
        kxx     += 1;
        show  = fxx + 1;    // pos fld show
        check = fxx + 2;    // pos fld show
        title = fxx + 3;    // pos fld show
        fxx = title ;
        if ( src.field.items[show].zwitch or src.field.items[check].zwitch ) {
            panel.button.append(btn.newButton(
                                            kbd.toEnum(@tagName(@as(kbd,@enumFromInt(kxx)))),    // function
                                            src.field.items[show].zwitch,    // show
                                            src.field.items[check].zwitch,    // check field
                                            src.field.items[title].text,    // title 
                                                )
                                        ) catch |err| { @panic(@errorName(err));};
        }

    }


    vNPANEL.name     = panel.name;
    vNPANEL.posx     = panel.posx;
    vNPANEL.posy     = panel.posy;
    vNPANEL.lines     = panel.lines;
    vNPANEL.cols     = panel.cols;
    vNPANEL.frame     = panel.frame;
    vNPANEL.button   = panel.button;
    vNPANEL.buf.clearAndFree(); 

    vXPANEL.name     = panel.name;
    vXPANEL.posx     = panel.posx;
    vXPANEL.posy     = panel.posy;
    vXPANEL.lines     = panel.lines;
    vXPANEL.cols     = panel.cols;
    vXPANEL.frame     = panel.frame;
    vXPANEL.button   = panel.button;
    
}
