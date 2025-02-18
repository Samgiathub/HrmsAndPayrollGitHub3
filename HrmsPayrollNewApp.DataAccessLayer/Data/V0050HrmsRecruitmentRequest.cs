using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050HrmsRecruitmentRequest
{
    public decimal RecReqId { get; set; }

    public string JobTitle { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public string EmpFullName { get; set; } = null!;

    public decimal? EmpId { get; set; }

    public string AlphaEmpCode { get; set; } = null!;

    public string WorkEmail { get; set; } = null!;

    public decimal? LoginId { get; set; }

    public DateTime PostedDate { get; set; }

    public decimal? GradeId { get; set; }

    public decimal? DesiId { get; set; }

    public string? QualificationDetail { get; set; }

    public string? ExperienceDetail { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? DeptId { get; set; }

    public string? SkillDetail { get; set; }

    public string? JobDescription { get; set; }

    public decimal NoOfVacancies { get; set; }

    public byte AppStatus { get; set; }

    public string TypeName { get; set; } = null!;

    public string? BranchCode { get; set; }

    public string BranchName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public string DeptName { get; set; } = null!;

    public string? EmpFirstName { get; set; }

    public DateTime? RecEndDate { get; set; }

    public decimal? BusinessSegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? TypeOfOpening { get; set; }

    public string? JobCode { get; set; }

    public decimal? JdCodeId { get; set; }

    public bool? Budgeted { get; set; }

    public double? ExpMin { get; set; }

    public double? ExpMax { get; set; }

    public string? RepEmployeeId { get; set; }

    public string Justification { get; set; } = null!;

    public decimal? CtcBudget { get; set; }

    public bool IsLeftReplaceEmpId { get; set; }

    public string Comments { get; set; } = null!;

    public string AttachDoc { get; set; } = null!;

    public string DocumentId { get; set; } = null!;

    public int? ExperienceType { get; set; }

    public decimal MinCtcBudget { get; set; }

    public string? MrfCode { get; set; }

    public int? CategoryId { get; set; }

    public string ManagerAttachDocs { get; set; } = null!;

    public string GenderSpecific { get; set; } = null!;
}
