using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAppraisalEmpPerformanceSummarySignoffHistory
{
    public decimal SignoffId { get; set; }

    public decimal FkPsId { get; set; }

    public decimal SignoffVersion { get; set; }

    public DateTime SignoffDate { get; set; }

    public decimal EmpId { get; set; }

    public virtual T0090HrmsAppraisalEmpPerformanceSummary FkPs { get; set; } = null!;
}
