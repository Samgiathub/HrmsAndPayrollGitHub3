using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewVehicleFinalNLevelApproval
{
    public int TranId { get; set; }

    public decimal EmpId { get; set; }

    public string EmpFullName { get; set; } = null!;

    public string? Supervisor { get; set; }

    public int VehicleAppId { get; set; }

    public string BranchName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public string AlphaEmpCode { get; set; } = null!;

    public DateTime? VehicleAppDate { get; set; }

    public string? AppStatus { get; set; }

    public int RptLevel { get; set; }

    public string SchemeId { get; set; } = null!;

    public string FinalApprover { get; set; } = null!;

    public int? VehicleId { get; set; }

    public string IsFwdLeaveRej { get; set; } = null!;

    public int IsIntimation { get; set; }

    public string? VehicleType { get; set; }

    public DateTime ApprovalDate { get; set; }

    public decimal SEmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? VehicleName { get; set; }

    public string VehicleAppStatus { get; set; } = null!;

    public string VehicleOption { get; set; } = null!;
}
