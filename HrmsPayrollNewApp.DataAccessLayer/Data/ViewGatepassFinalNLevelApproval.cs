using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewGatepassFinalNLevelApproval
{
    public decimal CmpId { get; set; }

    public decimal AppId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime AppDate { get; set; }

    public DateTime ForDate { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public string Duration { get; set; } = null!;

    public string? AppStatus { get; set; }

    public string? ReasonName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal SEmpIdA { get; set; }

    public decimal AprId { get; set; }

    public decimal RptLevel { get; set; }

    public string? EmpRemarks { get; set; }
}
