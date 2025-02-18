using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GrievAppAllocFullDetail
{
    public int GAllocationId { get; set; }

    public string? AppNo { get; set; }

    public int? CmpId { get; set; }

    public DateTime? AllocDate { get; set; }

    public string? AllocationDate { get; set; }

    public string HearingDate { get; set; } = null!;

    public string? ComName { get; set; }

    public string? GrievanceTypeTitle { get; set; }

    public string? CategoryTitle { get; set; }

    public string? PriorityTitle { get; set; }

    public string? SName { get; set; }

    public string? Comments { get; set; }

    public string? AllocDoc { get; set; }

    public string? GapplicationDate { get; set; }

    public string? Gafrom { get; set; }

    public string? NameFrom { get; set; }

    public string? RFrom { get; set; }

    public string? GrievAgainst { get; set; }

    public string? NameAgainst { get; set; }

    public string? AppSubline { get; set; }

    public string? AppDetails { get; set; }

    public DateTime? AppDate { get; set; }

    public string? AppDoc { get; set; }

    public DateTime? Ghdate { get; set; }

    public int? NodelHrId { get; set; }

    public int? ChairpersonId { get; set; }

    public decimal? ForLocationHearing { get; set; }

    public int? CommitteeId { get; set; }

    public int? TypeId { get; set; }

    public int? CatId { get; set; }

    public int? PriorityId { get; set; }

    public decimal? AppId { get; set; }

    public int? SId { get; set; }

    public int? AttemptHearing { get; set; }

    public int GhId { get; set; }

    public decimal EmpIdt { get; set; }
}
