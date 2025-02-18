using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0052HrmsRecruitementPosted
{
    public decimal? RecReqId { get; set; }

    public string? JobTitle { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? PostedDate { get; set; }

    public decimal? GradeId { get; set; }

    public decimal? DesiId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? DeptId { get; set; }

    public string? SkillDetail { get; set; }

    public string? JobDescription { get; set; }

    public decimal? NoOfVacancies { get; set; }

    public byte? AppStatus { get; set; }

    public string RecPostCode { get; set; } = null!;

    public DateTime RecPostDate { get; set; }

    public DateTime RecStartDate { get; set; }

    public DateTime? RecEndDate { get; set; }

    public string QualDetail { get; set; } = null!;

    public decimal ExperienceYear { get; set; }

    public string? Location { get; set; }

    public string Experience { get; set; } = null!;

    public string EmailId { get; set; } = null!;

    public byte PostedStatus { get; set; }

    public string? DesigName { get; set; }

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public decimal RecPostId { get; set; }

    public string? EmpFullName { get; set; }

    public string? TypeName { get; set; }

    public string? DomainName { get; set; }

    public string LocationPreference { get; set; } = null!;
}
