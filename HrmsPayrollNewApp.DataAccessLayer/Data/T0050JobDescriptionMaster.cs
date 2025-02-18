using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050JobDescriptionMaster
{
    public decimal JobId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public string JobCode { get; set; } = null!;

    public string? BranchId { get; set; }

    public string? GradeId { get; set; }

    public string? DesigId { get; set; }

    public string? DeptId { get; set; }

    public string? QualId { get; set; }

    public int? ExpMin { get; set; }

    public int? ExpMax { get; set; }

    public DateTime CreateDate { get; set; }

    public decimal CreateBy { get; set; }

    public string AttachDoc { get; set; } = null!;

    public int Status { get; set; }

    public string? JobTitle { get; set; }

    public int? SendToSuperior { get; set; }

    public string DocumentId { get; set; } = null!;

    public int? ExperienceType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0050HrmsRecruitmentRequest> T0050HrmsRecruitmentRequests { get; set; } = new List<T0050HrmsRecruitmentRequest>();

    public virtual ICollection<T0052HrmsRecruitmentRequestApproval> T0052HrmsRecruitmentRequestApprovals { get; set; } = new List<T0052HrmsRecruitmentRequestApproval>();

    public virtual ICollection<T0055JobDocument> T0055JobDocuments { get; set; } = new List<T0055JobDocument>();

    public virtual ICollection<T0055JobSkill> T0055JobSkills { get; set; } = new List<T0055JobSkill>();

    public virtual ICollection<T0090EmpJdResponsibilty> T0090EmpJdResponsibilties { get; set; } = new List<T0090EmpJdResponsibilty>();
}
