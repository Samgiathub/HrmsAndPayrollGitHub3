using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120PreCompOffApproval
{
    public decimal PreCompOffAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal PreCompOffAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal SEmpId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal Period { get; set; }

    public string? Remarks { get; set; }

    public string? ApprovalStatus { get; set; }
}
