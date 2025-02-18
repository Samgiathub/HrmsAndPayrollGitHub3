using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140LeaveTransactionBackup13072022
{
    public decimal LeaveTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LeaveOpening { get; set; }

    public decimal LeaveCredit { get; set; }

    public decimal LeaveUsed { get; set; }

    public decimal LeaveClosing { get; set; }

    public decimal? LeavePosting { get; set; }

    public decimal? LeaveAdjLMark { get; set; }

    public decimal? LeaveCancel { get; set; }

    public byte? EffInSalary { get; set; }

    public decimal LeaveEncashDays { get; set; }

    public byte ComoffFlag { get; set; }

    public decimal? ArrearUsed { get; set; }

    public decimal? BackDatedLeave { get; set; }

    public decimal CompOffCredit { get; set; }

    public decimal CompOffDebit { get; set; }

    public decimal CompOffBalance { get; set; }

    public decimal CompOffUsed { get; set; }

    public decimal HalfPaymentDays { get; set; }

    public decimal CfLapsDays { get; set; }
}
