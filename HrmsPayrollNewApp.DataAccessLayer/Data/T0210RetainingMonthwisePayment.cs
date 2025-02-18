using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210RetainingMonthwisePayment
{
    public decimal TranDId { get; set; }

    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public DateTime? CalMonth { get; set; }

    public DateTime? MonStartDate { get; set; }

    public DateTime? MonEndDate { get; set; }

    public decimal? Days { get; set; }

    public decimal? SlabId { get; set; }

    public decimal? SlabPer { get; set; }

    public string? Mode { get; set; }

    public decimal? PerDaySalary { get; set; }

    public decimal? RetainAmount { get; set; }

    public decimal? TotAmount { get; set; }

    public string? Remarks { get; set; }

    public DateTime? ModifyDate { get; set; }

    public int? TotRetainDays { get; set; }

    public decimal? BasicAmount { get; set; }

    public int? MonthDay { get; set; }
}
