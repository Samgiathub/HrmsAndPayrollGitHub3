using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class QrCodeMaster
{
    public Guid QrCodeId { get; set; }

    public int CmpId { get; set; }

    public int? BranchId { get; set; }

    public int? DepartmentId { get; set; }

    public bool IoFlag { get; set; }

    public int PosId { get; set; }

    public string Latitude { get; set; } = null!;

    public string Longitude { get; set; } = null!;

    public int Meters { get; set; }

    public bool IsActive { get; set; }

    public virtual PosMaster Pos { get; set; } = null!;
}
