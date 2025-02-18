using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0065EmpQualificationDetailAppGet
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public int RowId { get; set; }

    public int CmpId { get; set; }

    public int QualId { get; set; }

    public string? Specialization { get; set; }

    public decimal? Year { get; set; }

    public string? Score { get; set; }

    public string? StDate { get; set; }

    public string? EndDate { get; set; }

    public string? Comments { get; set; }

    public string QualName { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public int BranchId { get; set; }

    public string? BranchName { get; set; }

    public string? EmpFullName { get; set; }

    public string? DateOfJoin { get; set; }

    public string? QualType { get; set; }

    public string? AttachDoc { get; set; }
}
