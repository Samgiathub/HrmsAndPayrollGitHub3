using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0052HrmsRecruitmentPosted
{
    public decimal RecPostId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? RecReqId { get; set; }

    public string RecPostCode { get; set; } = null!;

    public DateTime RecPostDate { get; set; }

    public DateTime RecStartDate { get; set; }

    public DateTime? RecEndDate { get; set; }

    public decimal ExperienceYear { get; set; }

    public string QualId { get; set; } = null!;

    public string? Location { get; set; }

    public string? QualDetail { get; set; }

    public string Experience { get; set; } = null!;

    public string EmailId { get; set; } = null!;

    public string JobTitle { get; set; } = null!;

    public decimal? LoginId { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? SEmpId { get; set; }

    public string? JobDescription { get; set; }

    public decimal? NoOfVacancies { get; set; }

    public string? SkillDetail { get; set; }

    public byte? AppStatus { get; set; }

    public DateTime? PostedDate { get; set; }

    public decimal? BranchId { get; set; }

    public int PostedStatus { get; set; }

    public string? DesigName { get; set; }

    public string? Position { get; set; }

    public string? OtherDetail { get; set; }

    public string? DomainName { get; set; }

    public int TotalResume { get; set; }

    public string? CmpName { get; set; }

    public int TotalCandidate { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? DesiId { get; set; }

    public decimal? GradeId { get; set; }

    public decimal? BusinessSegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public string? VenueAddress { get; set; }

    public int? PublishToEmp { get; set; }

    public DateTime? PublishFromDate { get; set; }

    public DateTime? PublishToDate { get; set; }

    public string? TypeName { get; set; }

    public string SkillName { get; set; } = null!;

    public string? LocId { get; set; }

    public double? ExpMin { get; set; }
}
