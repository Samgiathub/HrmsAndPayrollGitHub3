using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080GrievApplicationAllocation
{
    public int GAllocationId { get; set; }

    public int? CmpId { get; set; }

    public int? CommitteeId { get; set; }

    public int? GrievTypeId { get; set; }

    public int? GrievCatId { get; set; }

    public int? GrievPriorityId { get; set; }

    public int? GrievStatusId { get; set; }

    public string? Comments { get; set; }

    public string? FileName { get; set; }

    public DateTime? Cdtm { get; set; }

    public DateTime? Udtm { get; set; }

    public string? Log { get; set; }

    public int? GrievAppId { get; set; }
}
