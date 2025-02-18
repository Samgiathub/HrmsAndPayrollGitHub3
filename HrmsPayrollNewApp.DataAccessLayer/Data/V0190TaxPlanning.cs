using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0190TaxPlanning
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal EmpCode1 { get; set; }

    public string? AlphaEmpCode { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public DateTime ForDate { get; set; }

    public decimal TaxableAmount { get; set; }

    public decimal ItYFinalAmount { get; set; }

    public decimal ItMFinalAmount { get; set; }

    public byte IsRepeat { get; set; }

    public decimal TranId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public string? EmpCode { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SalDateId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? SegmentId { get; set; }

    public string ItDeclarationCalcOn { get; set; } = null!;

    public string? Regime { get; set; }

    public string Activeclass { get; set; } = null!;
}
