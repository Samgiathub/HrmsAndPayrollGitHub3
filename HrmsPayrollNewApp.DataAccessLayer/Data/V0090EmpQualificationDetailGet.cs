using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpQualificationDetailGet
{
    public decimal EmpId { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal QualId { get; set; }

    public string? Specialization { get; set; }

    public decimal? Year { get; set; }

    public string? Score { get; set; }

    public string? StDate { get; set; }

    public string? EndDate { get; set; }

    public string? Comments { get; set; }

    public string QualName { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public string? EmpFullName { get; set; }

    public string? DateOfJoin { get; set; }

    public string? QualType { get; set; }

    public string? AttachDoc { get; set; }
}
