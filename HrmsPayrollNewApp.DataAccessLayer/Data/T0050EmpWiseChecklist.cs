using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050EmpWiseChecklist
{
    public decimal ChecklistId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? FillDate { get; set; }

    public decimal? TrainingId { get; set; }

    public decimal? TranId { get; set; }

    public string? FillUpChecklist { get; set; }

    public string? NotReqChecklist { get; set; }

    public string? FillDetails { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public string? IpAddress { get; set; }

    public byte PassingFlag { get; set; }

    public decimal TranFeedbackId { get; set; }

    public byte? TrainingAttemptCount { get; set; }
}
