using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999AuditTrail
{
    public decimal AuditTrailId { get; set; }

    public decimal CmpId { get; set; }

    public string AuditChangeType { get; set; } = null!;

    public string? AuditModuleName { get; set; }

    public string? AuditModulleDescription { get; set; }

    public decimal? AuditChangeFor { get; set; }

    public decimal? AuditChangeBy { get; set; }

    public DateTime AuditDate { get; set; }

    public string AuditIp { get; set; } = null!;

    public byte IsEmpId { get; set; }

    public string? KeyGuid { get; set; }
}
