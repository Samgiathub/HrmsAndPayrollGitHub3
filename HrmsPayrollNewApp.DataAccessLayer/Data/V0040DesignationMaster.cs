using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040DesignationMaster
{
    public decimal DesigId { get; set; }

    public decimal CmpId { get; set; }

    public decimal DesigDisNo { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal? DefId { get; set; }

    public decimal? ParentId { get; set; }

    public byte IsMain { get; set; }

    public string ParentName { get; set; } = null!;

    public string? DesigCode { get; set; }

    public byte AbscondingReminder { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public string? ModeOfTravel { get; set; }

    public string StatusColor { get; set; } = null!;
}
