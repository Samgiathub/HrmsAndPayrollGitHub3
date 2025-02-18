using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080GrievHearingHistory
{
    public int GhhId { get; set; }

    public int? CmpId { get; set; }

    public int? GHearingId { get; set; }

    public int? GStatusId { get; set; }

    public DateTime? LastHearingDate { get; set; }

    public DateTime? NextHearingDate { get; set; }

    public string? Ghhcomments { get; set; }

    public string? GhhdocName { get; set; }

    public DateTime? Cdtm { get; set; }

    public DateTime? Udtm { get; set; }

    public string? Log { get; set; }

    public string? Ghhlocation { get; set; }

    public decimal? Ghhcontact { get; set; }

    public int? GAllocationId { get; set; }
}
