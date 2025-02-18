using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V00130HrmsTrainingEmployeeDetail
{
    public decimal? EmpId { get; set; }

    public decimal? TrainingId { get; set; }

    public DateTime? TrainingDate { get; set; }

    public DateTime? TrainingEndDate { get; set; }

    public decimal? TrainingType { get; set; }

    public decimal CmpId { get; set; }

    public string Attend { get; set; } = null!;

    public string? TrainingName { get; set; }

    public decimal? EmpSId { get; set; }

    public int? Status { get; set; }
}
