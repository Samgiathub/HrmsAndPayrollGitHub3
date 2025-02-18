using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0052TraininigCalendar
{
    public decimal TrainingAprId { get; set; }

    public DateTime? TrainingEndDate { get; set; }

    public DateTime? TrainingDate { get; set; }

    public string? Type { get; set; }

    public string? TrainingName { get; set; }

    public int? AprStatus { get; set; }

    public decimal CmpId { get; set; }

    public string? BranchId { get; set; }
}
