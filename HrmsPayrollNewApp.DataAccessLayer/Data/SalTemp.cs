using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SalTemp
{
    public string? EmpName { get; set; }

    public string? GrdName { get; set; }

    public string? CompName { get; set; }

    public string? BranchAddress { get; set; }

    public string? EmpCode { get; set; }

    public string? TypeName { get; set; }

    public string? DeptName { get; set; }

    public string? DesignName { get; set; }

    public string? EmpFirstName { get; set; }

    public string? AdName { get; set; }

    public string? AdLevel { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? AdId { get; set; }

    public decimal? SalTranId { get; set; }

    public string? AdDescription { get; set; }

    public decimal? AdAmount { get; set; }

    public decimal? AdActualAmount { get; set; }

    public decimal? AdCalcAmount { get; set; }

    public DateTime? ForDate { get; set; }

    public string? MAdFlag { get; set; }

    public decimal? LoanId { get; set; }

    public decimal? DefId { get; set; }

    public decimal? MArrearDays { get; set; }

    public decimal? Ytd { get; set; }

    public decimal? AdAmtOnBasicForPer { get; set; }

    public decimal? BranchId { get; set; }

    public string? AlphaEmpCode { get; set; }
}
