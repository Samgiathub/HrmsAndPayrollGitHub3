

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0000_Reset_HRMSMail_Format]
	@Cmp_ID		numeric
AS
	begin

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


		if exists(Select 1 from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Email_Type='Recruitment Post Detail')
			begin
				update T0010_Email_Format_Setting set Email_Signature='<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <title>Message From Online Payroll</title>
    <style type="text/css">
        body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .skyblue
        {
            color: #7FDFFF;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            font-size: 24px;
        }
        .awards
        {
            font-size: 8.5pt;
            color: #000000;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            text-decoration: none;
            line-height: 15px;
        }
        .awards_detail
        {
            font-size: 15px;
            color: #FFCC00;
            font-family: arial;
            text-decoration: none;
            font-weight: bold;
            line-height: 20px;
        }
        .awards_detail1
        {
            font-size: 11px;
            color: #FFCC00;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 17px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_new
        {
            font-size: 12px;
            color: #333333;
            font-family: Arial;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_orange
        {
            font-size: 11px;
            color: #FF9900;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .dear_tab
        {
            background-image: url(images/deartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 53px;
            height: 26px;
            color: #7FDFFF;
            text-align: center;
            vertical-align: middle;
        }
        .name_dear_tab
        {
            background-image: url(images/afterdeartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 14px;
            width: 456px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            vertical-align: middle;
        }
        .leave-detail_tab
        {
            background-image: url(images/leavedetail.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 509px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            padding-left: 13px;
        }
        .message-from
        {
            font-family: arial;
            text-decoration: none;
 font-weight: normal;
            font-size: 18px;
            color: #7FDFFF;
            line-height: 20px;
        }
        .White
        {
            font-family: Verdana;
            font-size: 10pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
        .White_small
        {
            font-family: Verdana;
            font-size: 9pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
    </style>
    <link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <table width="580" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td align="center" valign="bottom">
                <table width="580" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="10" align="left" valign="top" bgcolor="#3D3C4C">
                            &nbsp;
                        </td>
                        <td width="560" align="left" valign="top" bgcolor="#3D3C4C">
                            <table width="572" height="56" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="491" height="37" align="center" valign="bottom" style="padding-bottom: 10px;
                                        color: #7FDFFF; font-family: Verdana; font-size: large">
                                        Message From Online Payroll
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="10" align="right" valign="top" bgcolor="#3D3C4C">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td bgcolor="#4F4E60" style="font-family: arial; text-decoration: none; font-weight: bold;
                width: 509px; height: 24px; color: #7FDFFF; text-align: left; padding: 10px 0px 10px 54px;">
                Recruitmet Posted Details
            </td>
        </tr>
    </table>
    <table width="580" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td height="200" align="left" valign="middle" bgcolor="#4F4E60" style="padding-bottom: 20px;">
                <table width="473" border="0" align="center" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="left" valign="bottom" bgcolor="#5f6275">
                            <table width="451" border="0" align="left" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td bgcolor="#5f6275" align="left" style="font-family: Verdana; font-size: 10pt;
                                        color: #ffffff; text-align: left; text-decoration: none;">
                                        Dear #EmpFullName#
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#5f6275" align="center" style="font-family: Verdana; font-size: 10pt;
                                        color: #ffffff; text-align: center; text-decoration: none;">
                                        <a style="color: #ffffff">#message#</a>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="451" align="center" valign="top">
                                        <table width="350" border="0" align="center" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td height="8" colspan="3">
</td>
                                            </tr>
                                            <tr>
                                                <td width="140" height="25" align="right" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        Job Title</div>
                                                </td>
                                                <td width="44" height="25" align="center" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="220" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #Job_Title#
                                                </td>
                                            </tr>
                                            <tr>
                                                <td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        Start Date
                                                    </div>
                                                </td>
                                                <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #Start_Date#
                                                </td>
                                            </tr>
                                            <tr>
                                                <td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        End Date</div>
                                                </td>
                                                <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                 </td>
                                                <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #End_Date#
                                                </td>
                                            </tr>
                                            <tr>
                                                <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        No Of Vacancies
                                                    </div>
                                                </td>
                                                <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #Vacancy#
                                                </td>
                                            </tr>
                                            <tr>
                                                <td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        Location
                                                    </div>
                                                </td>
                                                <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #Location#
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
               </table>
            </td>
        </tr>
        <tr>
            <td height="27" align="left" valign="middle" bgcolor="#6D7083" style="font-family: Verdana;
                font-size: 9pt; color: #ffffff; text-align: left; text-decoration: none;">
                <div align="center">
       Do not reply to this mail, this is a system generated mail.
                </div>
            </td>
        </tr>
        
    </table>
    #Signature#
</body>
</html>'
	where Email_Type='Recruitment Post Detail' and Cmp_Id=@Cmp_Id
end
		
	if exists(Select 1 from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Email_Type='Interview Approval')
			begin
				update T0010_Email_Format_Setting set Email_Signature='<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <title>Message FromMessage From Online Payroll</title>
    <style type="text/css">
        body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .skyblue
        {
            color: #7FDFFF;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            font-size: 24px;
        }
        .awards
        {
            font-size: 8.5pt;
            color: #000000;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            text-decoration: none;
            line-height: 15px;
        }
        .awards_detail
        {
            font-size: 15px;
            color: #FFCC00;
            font-family: arial;
            text-decoration: none;
            font-weight: bold;
            line-height: 20px;
        }
        .awards_detail1
        {
            font-size: 11px;
            color: #FFCC00;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 17px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_new
        {
            font-size: 12px;
            color: #333333;
            font-family: Arial;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_orange
        {
            font-size: 11px;
            color: #FF9900;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .dear_tab
        {
            background-image: url(images/deartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 53px;
            height: 26px;
            color: #7FDFFF;
            text-align: center;
            vertical-align: middle;
        }
        .name_dear_tab
        {
            background-image: url(images/afterdeartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 14px;
            width: 456px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            vertical-align: middle;
        }
        .leave-detail_tab
        {
            background-image: url(images/leavedetail.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 509px;
            height: 26px;
            color: #7FDFFF;
 text-align: left;
            padding-left: 13px;
        }
        .message-from
        {
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            color: #7FDFFF;
            line-height: 20px;
        }
        .White
        {
            font-family: Verdana;
            font-size: 10pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
        .White_small
        {
            font-family: Verdana;
            font-size: 9pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
    </style>
    <link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <table width="580" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td align="center" valign="bottom">
                <table width="580" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="10" align="left" valign="top" bgcolor="#3D3C4C">
                            &nbsp;
                        </td>
                        <td width="560" align="left" valign="top" bgcolor="#3D3C4C">
                            <table width="572" height="56" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="491" height="37" align="center" valign="bottom" style="padding-bottom: 10px;
                                        color: #7FDFFF; font-family: Verdana; font-size: large">
                                        Message From Online Payroll
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="10" align="right" valign="top" bgcolor="#3D3C4C">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td bgcolor="#4F4E60" style="font-family: arial; text-decoration: none; font-weight: bold;
                width: 509px; height: 26px; color: #7FDFFF; text-align: left; padding: 10px 0px 10px 54px;">
                Interview Details
            </td>
        </tr>
        <tr>
            <td height="237" align="left" valign="middle" bgcolor="#4F4E60" style="padding-bottom: 20px;">
                <table width="473" border="0" align="center" cellpadding="0" cellspacing="0">
                    <td align="left" valign="bottom" bgcolor="#5f6275">
                        <table width="451" border="0" align="left" cellpadding="0" cellspacing="0">
                            <tr>
                                <td bgcolor="#5f6275" align="left" style="font-family: Verdana; font-size: 10pt;
                                    color: #ffffff; text-align: left; text-decoration: none;">
                                    Dear #Name#
                                </td>
                            </tr>
                            <tr>
                                <td bgcolor="#5f6275">
                                   &nbsp;
                                </td>
                            </tr>
                            <tr>
                                <td bgcolor="#5f6275" align="left" style="font-family: Verdana; font-size: 10pt;
                                    color: #ffffff; text-align: left; text-decoration: none;">
                                    #message#
                                </td>
                            </tr>
                            <tr>
                                <td width="451" align="center" valign="top">
                                    <table width="350" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr>
                                            <td height="8" colspan="3">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="140" height="25" align="right" valign="middle" style="font-family: Verdana;
                                                font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                <div align="right">
                                                    Applicant Name</div>
                                            </td>
                                            <td width="44" height="25" align="center" valign="middle" style="font-family: Verdana;
                                                font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                <div align="center">
                                                    :
                                                </div>
                                            </td>
                                            <td width="220" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                #AppFullName#
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                color: #ffffff; text-align: left; text-decoration: none;">
                                                <div align="right">
                                                    Job Title
                                                </div>
                                            </td>
                                            <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                color: #ffffff; text-align: left; text-decoration: none;">
                                                <div align="center">
                                                    :
                                                </div>
                                            </td>
                                            <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                #Job_Title#
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                color: #ffffff; text-align: left; text-decoration: none;">
                                                <div align="right">
                                                    Interview Date</div>
                                            </td>
                                            <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                color: #ffffff; text-align: left; text-decoration: none;">
                                                <div align="center">
                                                    :
                                                </div>
                                            </td>
                    <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                #Process_Date#
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="25" align="center" valign="top" style="font-family: Verdana; font-size: 10pt;
                                                color: #ffffff; text-align: left; text-decoration: none;">
                                                <div align="right">
                                                    Location
                                                </div>
                                            </td>
                                            <td height="25" align="center" valign="top" style="font-family: Verdana; font-size: 10pt;
                                                color: #ffffff; text-align: left; text-decoration: none;">
                                                <div align="center">
                                                    :
                                                </div>
                                            </td>
                                            <td width="163" height="25" align="left" valign="top" style="font-family: Verdana;
                                                font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                #Location#
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                color: #ffffff; text-align: left; text-decoration: none;">
                                                <div align="right">
                                                    Timing
                                                </div>
                                            </td>
                                            <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                color: #ffffff; text-align: left; text-decoration: none;">
                                                <div align="center">
                                                    :
                                                </div>
                                            </td>
                                            <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                #time#
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
        </tr>
    </table>
    <tr>
        <td height="27" align="left" valign="middle" bgcolor="#6D7083" style="font-family: Verdana;
            font-size: 9pt; color: #ffffff; text-align: left; text-decoration: none;">
            <div align="center">
                Do not reply to this mail, this is a system generated mail.
            </div>
        </td>
    </tr>
   
    </table> 
    #Signature#
</body>
</html>'
where Email_Type='Interview Approval' and Cmp_Id=@Cmp_Id
end
	
	if exists(Select 1 from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Email_Type='Interview Call')
			begin
				update T0010_Email_Format_Setting set Email_Signature='<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <title>Message FromMessage From Online Payroll</title>
    <style type="text/css">
        body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .skyblue
        {
            color: #7FDFFF;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            font-size: 24px;
        }
        .awards
        {
            font-size: 8.5pt;
            color: #000000;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            text-decoration: none;
            line-height: 15px;
        }
        .awards_detail
        {
            font-size: 15px;
            color: #FFCC00;
            font-family: arial;
            text-decoration: none;
            font-weight: bold;
            line-height: 20px;
        }
        .awards_detail1
        {
            font-size: 11px;
            color: #FFCC00;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 17px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_new
        {
            font-size: 12px;
            color: #333333;
            font-family: Arial;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_orange
        {
            font-size: 11px;
            color: #FF9900;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .dear_tab
        {
            background-image: url(images/deartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 53px;
            height: 26px;
            color: #7FDFFF;
            text-align: center;
            vertical-align: middle;
        }
        .name_dear_tab
        {
            background-image: url(images/afterdeartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 14px;
            width: 456px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            vertical-align: middle;
        }
        .leave-detail_tab
        {
            background-image: url(images/leavedetail.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 509px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            padding-left: 13px;
        }
        .message-from
        {
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            color: #7FDFFF;
            line-height: 20px;
        }
        .White
        {
            font-family: Verdana;
            font-size: 10pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
        .White_small
        {
            font-family: Verdana;
            font-size: 9pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
    </style>
    <link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <table width="580" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td bgcolor="#4F4E60" style="font-family: arial; text-decoration: none; font-weight: bold;
                width: 509px; height: 26px; color: #7FDFFF; text-align: left; padding: 10px 0px 10px 54px;">
                Interview Details
            </td>
        </tr>
        <tr>
            <td height="237" align="left" valign="middle" bgcolor="#4F4E60" style="padding-bottom: 20px;">
                <table width="473" border="0" align="center" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="left" valign="bottom" bgcolor="#5f6275">
                            <table width="451" border="0" align="left" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td bgcolor="#5f6275" align="left" style="font-family: Verdana; font-size: 10pt;
                                        color: #ffffff; text-align: left; text-decoration: none;">
                                        Dear #Name#
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#5f6275">
                                        &nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#5f6275" align="left" style="font-family: Verdana; font-size: 10pt;
                                        color: #ffffff; text-align: left; text-decoration: none;">
                                        #message#
                                    </td>
                                </tr>
                                <tr>
                                    <td width="451" align="center" valign="top">
                                        <table width="350" border="0" align="center" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td height="8" colspan="3">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="140" height="25" align="right" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        Job Title</div>
                                                </td>
                                                <td width="44" height="25" align="center" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="220" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #Job_Title#
                                                </td>
                                            </tr>
                                            <tr>
                                                <td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        Interview Date</div>
                                                </td>
                                                <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #Process_Date#
                                                </td>
                                            </tr>
                                            <tr>
                                                <td height="25" align="center" valign="top" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        Location
                                                    </div>
                                                </td>
                                                <td height="25" align="center" valign="top" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="163" height="25" align="left" valign="top" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #Location#
                                                </td>
                                            </tr>
                                            <tr>
                                                <td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        Contact Person
                                                    </div>
                                                </td>
                                                <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
<div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #Emp_Name#
                                                </td>
                                            </tr>
                                            <tr>
                                                <td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        Timing
                                                    </div>
                                                </td>
                                                <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #time#
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td height="27" align="left" valign="middle" bgcolor="#6D7083" style="font-family: Verdana;
                font-size: 9pt; color: #ffffff; text-align: left; text-decoration: none;">
                <div align="center">
                    Do not reply to this mail, this is a system generated mail.
                </div>
            </td>
        </tr>
     
    </table>
      #Signature#
</body>
</html>'
where Email_Type='Interview Call' and Cmp_Id=@Cmp_Id
			
end

if exists(Select 1 from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Email_Type='Offer Letter')
			begin
				update T0010_Email_Format_Setting set Email_Signature='<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <title>Message FromMessage From Online Payroll</title>
    <style type="text/css">
        body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .skyblue
        {
            color: #7FDFFF;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            font-size: 24px;
        }
        .awards
        {
            font-size: 8.5pt;
            color: #000000;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            text-decoration: none;
            line-height: 15px;
        }
        .awards_detail
        {
            font-size: 15px;
            color: #FFCC00;
            font-family: arial;
            text-decoration: none;
            font-weight: bold;
            line-height: 20px;
        }
        .awards_detail1
        {
            font-size: 11px;
            color: #FFCC00;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 17px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_new
        {
            font-size: 12px;
            color: #333333;
            font-family: Arial;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_orange
        {
            font-size: 11px;
            color: #FF9900;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .dear_tab
        {
            background-image: url(images/deartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 53px;
            height: 26px;
            color: #7FDFFF;
            text-align: center;
            vertical-align: middle;
        }
        .name_dear_tab
        {
            background-image: url(images/afterdeartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 14px;
            width: 456px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            vertical-align: middle;
        }
        .leave-detail_tab
        {
            background-image: url(images/leavedetail.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 509px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            padding-left: 13px;
        }
        .message-from
        {
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            color: #7FDFFF;
            line-height: 20px;
        }
        .White
        {
            font-family: Verdana;
            font-size: 10pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
        .White_small
        {
            font-family: Verdana;
            font-size: 9pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
    </style>
    <link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <table width="580" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td height="237" align="left" valign="middle" bgcolor="#4F4E60" style="padding-bottom: 20px;">
                <table width="473" border="0" align="center" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="left" valign="top" bgcolor="#5f6275">
                            <table width="571" border="0" align="left" cellpadding="0" cellspacing="0">
                                <tr>
                                <td>
                                        &nbsp;&nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" style="font-family: Verdana; font-size: 10pt; color: #ffffff; text-align: left;
                                        text-decoration: none;">
                                        <div align="left">
                                            Dear #ApplicantName#
                                        </div>
                                    </td>
                                </tr>  
                                <tr>
                                    <td>
                                        &nbsp;&nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" style="font-family: Verdana; font-size: 10pt; color: #ffffff; text-align: left;
                                        text-decoration: none;">
                                        <div align="left">
                                            Congratulations !!
                                            <br />
                                            We are happy to offer you the post of "#Designation#", at our "#BranchName#" branch.
                                            You are requested to carry the following documents in original (along with a copy),
                                            on your date of joining #JoinDate#.</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" style="font-family: Verdana; font-size: 10pt; color: #ffffff; text-align: left;
                                        text-decoration: none;">
                                        <div align="left">
                                            1. Passport size photograph (# 2)
                                            <br />
                                            2. Address Proof.<br />
                                            3. Identity Proof.<br />
                                            4. Educational & Professional Certificates & Mark-sheets.<br />
                                            5. Secondary (Matriculation) Board Examination (Class 10) Registration Certificate.<br />
                                            6. PAN (in case of absence of PAN, Application Acknowledgement receipt required).<br />
                                            7. Previous Employment TDS, Salary Slips, Appointment Letter, Appraisal Letter
                                            and Release Letter.
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;&nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" style="font-family: Verdana; font-size: 10pt; color: #ffffff; text-align: left;
                                        text-decoration: none;">
                                        <div align="left">
                                            Kindly ensure that your details are filled in the following link #link#.<br />
                                            Please Note : 1) The link will be active for only 10 days.
                                            <br />
                                            2) The link will not open if you have previously locked it.
                                        </div>
                                    </td>
              </tr>
                                <tr>
                                    <td align="left" style="font-family: Verdana; font-size: 10pt; color: #ffffff; text-align: left;
                                        text-decoration: none;">
                                        <div align="left">
                                            <a style="color: #ffffff">#Accept Offer Letter# &nbsp;&nbsp; #Reject Offer Letter#</a>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;&nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" style="font-family: Verdana; font-size: 10pt; color: #ffffff; text-align: left;
                                        text-decoration: none;">
                                        <div align="left">
                                            For #Signature#
                                            <br />
                                            Team HR
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td height="27" align="left" valign="middle" bgcolor="#6D7083" style="font-family: Verdana;
                font-size: 9pt; color: #ffffff; text-align: left; text-decoration: none;">
                <div align="center">
                    Do not reply to this mail, this is a system generated mail.
                </div>
            </td>
        </tr>
    </table>
    #Signature#
</body>
</html>'
	where Email_Type='Offer Letter' and Cmp_Id=@Cmp_Id
end			


if exists(Select 1 from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Email_Type='Candidate Rejection')
			begin
				update T0010_Email_Format_Setting set Email_Signature='<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <title>Message FromMessage From Online Payroll</title>
    <style type="text/css">
        body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .skyblue
        {
            color: #7FDFFF;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            font-size: 24px;
        }
        .awards
        {
            font-size: 8.5pt;
            color: #000000;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            text-decoration: none;
            line-height: 15px;
        }
        .awards_detail
        {
            font-size: 15px;
            color: #FFCC00;
            font-family: arial;
            text-decoration: none;
            font-weight: bold;
            line-height: 20px;
        }
        .awards_detail1
        {
            font-size: 11px;
            color: #FFCC00;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 17px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_new
        {
            font-size: 12px;
            color: #333333;
            font-family: Arial;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
  font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_orange
        {
            font-size: 11px;
            color: #FF9900;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .dear_tab
        {
            background-image: url(images/deartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 53px;
            height: 26px;
            color: #7FDFFF;
            text-align: center;
            vertical-align: middle;
        }
        .name_dear_tab
        {
            background-image: url(images/afterdeartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 14px;
            width: 456px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            vertical-align: middle;
        }
        .leave-detail_tab
        {
            background-image: url(images/leavedetail.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 509px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            padding-left: 13px;
        }
        .message-from
        {
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            color: #7FDFFF;
            line-height: 20px;
        }
        .White
        {
            font-family: Verdana;
            font-size: 10pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
        .White_small
        {
            font-family: Verdana;
            font-size: 9pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
    </style>
    <link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <table width="580" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td align="center" valign="bottom">
                <table width="580" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="10" align="left" valign="top" bgcolor="#3D3C4C">
                            &nbsp;
                        </td>
                        <td width="560" align="left" valign="top" bgcolor="#3D3C4C">
                            <table width="572" height="26" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="font-family: Verdana; font-size: 10pt; color: #ffffff;
                                        text-decoration: none; padding-bottom: 10px;">
                                        #message#
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="10" align="right" valign="top" bgcolor="#3D3C4C">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td height="237" align="left" valign="middle" bgcolor="#4F4E60" style="padding-bottom: 20px;">
          <table width="473" border="0" align="center" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="left" valign="top" bgcolor="#5f6275">
                            <table width="571" border="0" align="left" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="left" style="font-family: Verdana; font-size: 10pt; color: #ffffff; text-align: left;
                                        text-decoration: none;">
                                        <div align="left">
                                            Dear #ApplicantName# ,</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" style="font-family: Verdana; font-size: 10pt; color: #ffffff; text-align: left;
                                        text-decoration: none;">
                                        <div align="left">
                                            <br />
                                            Thank you for taking the time out of your busy schedule to come and meet with us
                                            for the position of #JobTitle#. We very much appreciated your professional attitude
                                            and skills and enjoyed interviewing you for the position. We were very impressed
                                            with your capabilities and agree you have a great deal to offer. However, after
                                            much discussion and deliberation, we finally concluded that although we were quite
                                            impressed by your credentials, we have unfortunately decided to fill the position
                                            with another candidate whose qualifications and background we felt were a better
                                            fit for the role and the team at this stage. Although we are not able to select
                                            you for this job position at this time, however we are going to take the liberty
                                            of saving your resume for future job opportunities that may arise. Our interview
                                            team was impressed by your experience and the values you may bring to our company,
                                            so please do not hesitate to apply for other open positions that may arise at our
                                            company. Once again, thank you for your interest and best wishes of success for
                                            your future endeavors.
                                            <br />
                                            <br />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="27" align="left" valign="middle" bgcolor="#6D7083" style="font-family: Verdana;
                            font-size: 9pt; color: #ffffff; text-align: left; text-decoration: none;">
                            <div align="center">
                                Do not reply to this mail, this is a system generated mail.
                            </div>
                        </td>
                    </tr>
                
                </table>
              #Signature#
</body>
</html>'
where Email_Type='Candidate Rejection' and Cmp_Id=@Cmp_Id	
				
end

if exists(Select 1 from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Email_Type='Appraisal Initiation')
			begin
				update T0010_Email_Format_Setting set Email_Signature='
				<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <title>Message FromMessage From Online Payroll</title>
    <style type="text/css">
        body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .body
        {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        .skyblue
        {
            color: #7FDFFF;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            font-size: 24px;
        }
        .awards
        {
            font-size: 8.5pt;
            color: #000000;
            font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
            text-decoration: none;
            line-height: 15px;
        }
        .awards_detail
        {
            font-size: 15px;
            color: #FFCC00;
            font-family: arial;
            text-decoration: none;
            font-weight: bold;
            line-height: 20px;
        }
        .awards_detail1
        {
            font-size: 11px;
            color: #FFCC00;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 17px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_new
        {
            font-size: 12px;
            color: #333333;
            font-family: Arial;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .awards_detail1_orange
        {
            font-size: 11px;
            color: #FF9900;
            font-family: Verdana;
            font-weight: 300;
            text-align: justify;
            line-height: 18px;
            font-stretch: normal;
            font-weight: 100;
            font-style: normal;
        }
        .dear_tab
        {
            background-image: url(images/deartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 53px;
            height: 26px;
            color: #7FDFFF;
            text-align: center;
            vertical-align: middle;
        }
        .name_dear_tab
        {
            background-image: url(images/afterdeartab.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 14px;
            width: 456px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            vertical-align: middle;
        }
        .leave-detail_tab
        {
            background-image: url(images/leavedetail.jpg);
            background-position: left;
            background-repeat: no-repeat;
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            width: 509px;
            height: 26px;
            color: #7FDFFF;
            text-align: left;
            padding-left: 13px;
        }
        .message-from
        {
            font-family: arial;
            text-decoration: none;
            font-weight: normal;
            font-size: 18px;
            color: #7FDFFF;
            line-height: 20px;
        }
        .White
        {
            font-family: Verdana;
            font-size: 10pt;
            color: #ffffff;
            text-align: left;
  text-decoration: none;
        }
        .White_small
        {
            font-family: Verdana;
            font-size: 9pt;
            color: #ffffff;
            text-align: left;
            text-decoration: none;
        }
    </style>
    <link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <table width="580" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td align="center" valign="bottom">
                <table width="580" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="10" align="left" valign="top" bgcolor="#3D3C4C">
                            &nbsp;
                        </td>
                        <td width="560" align="left" valign="top" bgcolor="#3D3C4C">
                            <table width="572" height="56" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="491" height="37" align="center" valign="bottom" style="padding-bottom: 10px;
                                        color: #7FDFFF; font-family: Verdana; font-size: large">
                                        Message From Online Payroll
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="font-family: Verdana; font-size: 10pt; color: #ffffff; text-decoration: none;
                                        padding-bottom: 10px;">
                                        #message#
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="10" align="right" valign="top" bgcolor="#3D3C4C">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td bgcolor="#4F4E60" style="font-family: arial; text-decoration: none; font-weight: bold;
                width: 509px; height: 26px; color: #7FDFFF; text-align: left; padding: 10px 0px 10px 54px;">
                Appraisal Details
            </td>
        </tr>
        <tr>
            <td height="237" align="left" valign="middle" bgcolor="#4F4E60" style="padding-bottom: 20px;">
                <table width="473" border="0" align="center" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="left" valign="bottom" bgcolor="#5f6275">
                            <table width="451" border="0" align="left" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="451" align="center" valign="top">
                                        <table width="350" border="0" align="center" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td height="8" colspan="3">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="140" height="25" align="right" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        Appraisal Status</div>
                                                </td>
                                                <td width="44" height="25" align="center" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="220" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #status#
                                                </td>
                                            </tr>
                                            <tr>
                                                <td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="right">
                                                        For Date
                                                    </div>
                                                </td>
                                                <td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
                                                    color: #ffffff; text-align: left; text-decoration: none;">
                                                    <div align="center">
                                                        :
                                                    </div>
                                                </td>
                                                <td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
                                                    font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
                                                    #For_Date#
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    
                </table>
            </td>
        </tr>
        <tr>
            <td height="27" align="left" valign="middle" bgcolor="#6D7083" style="font-family: Verdana;
                font-size: 9pt; color: #ffffff; text-align: left; text-decoration: none;">
                <div align="center">
					Do not reply to this mail, this is a system generated mail.
                </div>
            </td>
        </tr>
        <tr>
                        <td height="27" align="left" valign="middle" bgcolor="#6D7083" style="font-family: Verdana;
                            font-size: 9pt; color: #ffffff; text-align: left; text-decoration: none;">
                            <div align="left">
                                #Signature#
                            </div>
                        </td>
                    </tr>
    </table>
    
</body>
</html>'
where Email_Type='Appraisal Initiation' and Cmp_Id=@Cmp_Id	

				end

end




