using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100TrainingApplication
{
    public decimal TrainingAppId { get; set; }

    public string TrainingTitle { get; set; } = null!;

    public string? TrainingDesc { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? PostedEmpId { get; set; }

    public decimal SkillId { get; set; }

    public string AppStatus { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040SkillMaster Skill { get; set; } = null!;

    public virtual ICollection<T0110TrainingApplicationDetail> T0110TrainingApplicationDetails { get; set; } = new List<T0110TrainingApplicationDetail>();

    public virtual ICollection<T0120TrainingApproval> T0120TrainingApprovals { get; set; } = new List<T0120TrainingApproval>();
}
