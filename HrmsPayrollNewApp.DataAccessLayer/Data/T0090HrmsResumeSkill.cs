using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsResumeSkill
{
    public decimal RowId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SkillId { get; set; }

    public string SkillComments { get; set; } = null!;

    public string? SkillExperience { get; set; }

    public string? AttachDocuments { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;

    public virtual T0040SkillMaster Skill { get; set; } = null!;
}
