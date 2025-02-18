using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100LeftEmp
{
    public decimal LeftId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? UniformReturn { get; set; }

    public decimal? ExitInterview { get; set; }

    public decimal? NoticePeriod { get; set; }

    public DateTime LeftDate { get; set; }

    public string LeftReason { get; set; } = null!;

    public string? NewEmployer { get; set; }

    public DateTime RegAcceptDate { get; set; }

    public byte IsTerminate { get; set; }

    public byte IsDeath { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpFirstName { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public string? Gender { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public string? GrdName { get; set; }

    public string? DeptName { get; set; }

    public string? BranchName { get; set; }

    public string? DesigName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public DateTime? RegDate { get; set; }

    public decimal? RptManagerId { get; set; }

    public decimal IsRetire { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public string? LeftReasonValue { get; set; }

    public string? LeftReasonText { get; set; }

    public int? ResId { get; set; }

    public string ReasonType { get; set; } = null!;

    public string? LeftReasonName { get; set; }

    public byte IsAbsconded { get; set; }
}
