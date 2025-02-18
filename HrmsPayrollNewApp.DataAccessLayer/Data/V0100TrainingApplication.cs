using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100TrainingApplication
{
    public decimal TrainingAppId { get; set; }

    public string TrainingTitle { get; set; } = null!;

    public string? TrainingDesc { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? PostedEmpId { get; set; }

    public string AppStatus { get; set; } = null!;

    public decimal SkillId { get; set; }

    public string? SkillName { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }
}
