using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100LeaveCfAdvanceLeaveBalance
{
    public decimal LeaveTranId { get; set; }

    public decimal? LeaveCfId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? LeaveId { get; set; }

    public DateTime? CfForDate { get; set; }

    public DateTime? CfFromDate { get; set; }

    public DateTime? CfToDate { get; set; }

    public string? CfType { get; set; }

    public byte IsFnf { get; set; }

    public decimal AdvanceLeaveBalance { get; set; }

    public DateTime? LastModifyDate { get; set; }

    public decimal? LastModifyBy { get; set; }

    public bool? CfIsMakerChecker { get; set; }
}
