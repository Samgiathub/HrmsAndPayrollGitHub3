using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsResumeSkill
{
    public decimal ResumeId { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SkillId { get; set; }

    public string? SkillName { get; set; }

    public string SkillComments { get; set; } = null!;

    public string? SkillExperience { get; set; }

    public string? ResumeCode { get; set; }

    public string AttachDocuments { get; set; } = null!;
}
