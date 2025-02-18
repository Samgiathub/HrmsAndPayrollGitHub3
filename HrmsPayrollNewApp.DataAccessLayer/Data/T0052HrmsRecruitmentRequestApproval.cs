using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052HrmsRecruitmentRequestApproval
{
    public decimal RecAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? RecReqId { get; set; }

    public decimal? ApproverEmpId { get; set; }

    public int? IsFinal { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RecAppStatus { get; set; }

    public int? RptLevel { get; set; }

    public string? JobTitle { get; set; }

    public decimal? GradeId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? DeptId { get; set; }

    public string? SkillDetail { get; set; }

    public string? JobDescription { get; set; }

    public decimal? NoOfVacancies { get; set; }

    public string? QualificationDetail { get; set; }

    public string? ExperienceDetail { get; set; }

    public decimal? BusinessSegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? TypeOfOpening { get; set; }

    public decimal? JdCodeId { get; set; }

    public bool? Budgeted { get; set; }

    public double? ExpMin { get; set; }

    public double? ExpMax { get; set; }

    public string? RepEmployeeId { get; set; }

    public string Justification { get; set; } = null!;

    public decimal? CtcBudget { get; set; }

    public bool IsLeftReplaceEmpId { get; set; }

    public string Comments { get; set; } = null!;

    public string? AttachDoc { get; set; }

    public string DocumentId { get; set; } = null!;

    public int? ExperienceType { get; set; }

    public decimal? MinCtcBudget { get; set; }

    public int? CategoryId { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0040BusinessSegment? BusinessSegment { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040GradeMaster? Grade { get; set; }

    public virtual T0050JobDescriptionMaster? JdCode { get; set; }

    public virtual T0050HrmsRecruitmentRequest? RecReq { get; set; }

    public virtual T0050SubVertical? SubVertical { get; set; }

    public virtual ICollection<T0115RecruitmentSkillLevel> T0115RecruitmentSkillLevels { get; set; } = new List<T0115RecruitmentSkillLevel>();

    public virtual T0040TypeMaster? Type { get; set; }

    public virtual T0040VerticalSegment? Vertical { get; set; }
}
