using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110TaskAudit
{
    public int TaskAuditId { get; set; }

    public int? TaskId { get; set; }

    public int? TaskDetailId { get; set; }

    public string? TaskField { get; set; }

    public string? TaskOldValue { get; set; }

    public string? TaskNewValue { get; set; }

    public int? UpdatedEmpId { get; set; }

    public DateTime? TaskUpdatedDate { get; set; }
}
