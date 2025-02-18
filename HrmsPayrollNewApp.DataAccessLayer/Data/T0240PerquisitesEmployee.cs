using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0240PerquisitesEmployee
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal PerquisitesId { get; set; }

    public string FinancialYear { get; set; } = null!;

    public byte OnRent { get; set; }

    public DateTime? OnRentFrom { get; set; }

    public DateTime? OnRentTo { get; set; }

    public byte CmpQuarter { get; set; }

    public DateTime? CmpQuarterFrom { get; set; }

    public DateTime CmpQuarterTo { get; set; }

    public decimal Salary { get; set; }

    public decimal OnRentPer { get; set; }

    public decimal CmpQuaterPer { get; set; }

    public decimal TotalRentAmt { get; set; }

    public decimal TotalFurnishAmt { get; set; }

    public string? Population { get; set; }

    public decimal? OnRentDays { get; set; }

    public decimal? CmpQuarterDays { get; set; }

    public decimal Month { get; set; }

    public decimal PerRentAmt { get; set; }

    public decimal PerQuaterAmt { get; set; }

    public DateTime? ChangeDate { get; set; }
}
