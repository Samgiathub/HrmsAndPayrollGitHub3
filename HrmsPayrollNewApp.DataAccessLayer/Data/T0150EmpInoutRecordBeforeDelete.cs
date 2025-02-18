using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150EmpInoutRecordBeforeDelete
{
    public decimal IoTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? OutTime { get; set; }

    public string? Duration { get; set; }

    public string? Reason { get; set; }

    public string IpAddress { get; set; } = null!;

    public DateTime? InDateTime { get; set; }

    public DateTime? OutDateTime { get; set; }

    public decimal? SkipCount { get; set; }

    public decimal? LateCalcNotApp { get; set; }

    public byte? ChkBySuperior { get; set; }

    public string? SupComment { get; set; }

    public string? HalfFullDay { get; set; }

    public byte? IsCancelLateIn { get; set; }

    public byte? IsCancelEarlyOut { get; set; }

    public byte? IsDefaultIn { get; set; }

    public byte? IsDefaultOut { get; set; }

    public decimal CmpPrpInFlag { get; set; }

    public decimal CmpPrpOutFlag { get; set; }

    public byte IsCmpPurpose { get; set; }

    public DateTime? AppDate { get; set; }

    public DateTime? AprDate { get; set; }

    public DateTime? SystemDate { get; set; }

    public string? OtherReason { get; set; }

    public string? ManualEntryFlag { get; set; }

    public int? UserId { get; set; }
}
