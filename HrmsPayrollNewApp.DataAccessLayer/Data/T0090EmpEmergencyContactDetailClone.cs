using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpEmergencyContactDetailClone
{
    public decimal EmpId { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public string Name { get; set; } = null!;

    public string RelationShip { get; set; } = null!;

    public string HomeTelNo { get; set; } = null!;

    public string HomeMobileNo { get; set; } = null!;

    public string WorkTelNo { get; set; } = null!;

    public DateTime SystemDate { get; set; }

    public decimal LoginId { get; set; }
}
