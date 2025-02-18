using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115PreCompOffApprovalLevel
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal PreCompOffAppId { get; set; }

    public DateTime? PrecompOffAppDate { get; set; }

    public DateTime? PreCompOffAprDate { get; set; }

    public decimal EmpId { get; set; }

    public decimal SEmpId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal Period { get; set; }

    public string? Remarks { get; set; }

    public string? ApprovalStatus { get; set; }

    public byte? RptLevel { get; set; }

    public byte? FinalApproval { get; set; }

    public byte? IsFwdReject { get; set; }
}
