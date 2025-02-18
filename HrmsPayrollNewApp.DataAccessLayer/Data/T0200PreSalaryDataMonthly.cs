using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200PreSalaryDataMonthly
{
    public decimal TranId { get; set; }

    public string? Type { get; set; }

    public string? MSalTranId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? SalGenerateDate { get; set; }

    public DateTime? MonthStDate { get; set; }

    public DateTime? MonthEndDate { get; set; }

    public decimal? MOtHours { get; set; }

    public decimal? AreasAmount { get; set; }

    public decimal? MItTax { get; set; }

    public decimal? OtherDedu { get; set; }

    public decimal? MLoanAmount { get; set; }

    public decimal? MAdvAmount { get; set; }

    public decimal? IsLoanDedu { get; set; }

    public decimal? LoginId { get; set; }

    public string? ErrRaise { get; set; }

    public string? IsNegetive { get; set; }

    public string? Status { get; set; }

    public decimal? ItMEdCessAmount { get; set; }

    public decimal? ItMSurchargeAmount { get; set; }

    public decimal? AlloOnLeave { get; set; }

    public decimal? WOtHours { get; set; }

    public decimal? HOtHours { get; set; }

    public decimal? UserId { get; set; }

    public string? IpAddress { get; set; }

    public decimal IsProcessed { get; set; }

    public string? BatchId { get; set; }

    public bool? IsBondDedu { get; set; }
}
