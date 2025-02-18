using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SkillMaster
{
    public decimal SkillId { get; set; }

    public decimal CmpId { get; set; }

    public string? SkillName { get; set; }

    public string? Description { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0055HrmsSkillRateDetail> T0055HrmsSkillRateDetails { get; set; } = new List<T0055HrmsSkillRateDetail>();

    public virtual ICollection<T0055JobSkill> T0055JobSkills { get; set; } = new List<T0055JobSkill>();

    public virtual ICollection<T0055RecruitmentSkill> T0055RecruitmentSkills { get; set; } = new List<T0055RecruitmentSkill>();

    public virtual ICollection<T0090HrmsEmpSkillSetting> T0090HrmsEmpSkillSettings { get; set; } = new List<T0090HrmsEmpSkillSetting>();

    public virtual ICollection<T0090HrmsResumeSkill> T0090HrmsResumeSkills { get; set; } = new List<T0090HrmsResumeSkill>();

    public virtual ICollection<T0100HrmsTrainingApplication> T0100HrmsTrainingApplications { get; set; } = new List<T0100HrmsTrainingApplication>();

    public virtual ICollection<T0100TrainingApplication> T0100TrainingApplications { get; set; } = new List<T0100TrainingApplication>();
}
