using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050JobDescriptionMaster
{
    public decimal JobId { get; set; }

    public decimal CmpId { get; set; }

    public string JobCode { get; set; } = null!;

    public DateTime EffectiveDate { get; set; }

    public int? ExpMin { get; set; }

    public int? ExpMax { get; set; }

    public string? BranchId { get; set; }

    public string? GradeId { get; set; }

    public string? DesigId { get; set; }

    public string? DeptId { get; set; }

    public string? QualId { get; set; }

    public string? BranchName { get; set; }

    public string? GrdName { get; set; }

    public string? DeptName { get; set; }

    public string? DesigName { get; set; }

    public string? QualName { get; set; }

    public string AttachDoc { get; set; } = null!;

    public string Status { get; set; } = null!;

    public string JobTitle { get; set; } = null!;

    public string DocumentId { get; set; } = null!;

    public int? ExperienceType { get; set; }
}
