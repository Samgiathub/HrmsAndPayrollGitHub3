using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100RcApplication
{
    public decimal CmpId { get; set; }

    public decimal RcAppId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime AppDate { get; set; }

    public decimal? TaxFreeAmount { get; set; }

    public decimal? TaxAmount { get; set; }

    public decimal AppTaxFreeAmount { get; set; }

    public decimal? AppTaxAmount { get; set; }

    public decimal AprTaxFreeAmount { get; set; }

    public decimal AprTaxAmount { get; set; }

    public decimal AppAmount { get; set; }

    public decimal? TaxableAmount { get; set; }

    public string? AppComments { get; set; }

    public byte AppStatus { get; set; }

    public DateTime? LeaveFromDate { get; set; }

    public string? Fy { get; set; }

    public DateTime? LeaveToDate { get; set; }

    public decimal? Days { get; set; }

    public byte? IsManagerRecord { get; set; }

    public decimal? RcAprId { get; set; }

    public decimal? EmpSuperior { get; set; }

    public decimal? BranchId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string Taxable { get; set; } = null!;

    public string AdName { get; set; } = null!;

    public string? Status { get; set; }

    public string? DraftStatus { get; set; }

    public decimal? SEmpId { get; set; }

    public string? DesigName { get; set; }

    public string CmpName { get; set; } = null!;

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public decimal? AdDefId { get; set; }

    public decimal RcId { get; set; }

    public DateTime DateOfJoin { get; set; }

    public string? MobileNo { get; set; }

    public string? CatName { get; set; }

    public DateTime? AprDate { get; set; }

    public byte SubmitFlag { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }
}
