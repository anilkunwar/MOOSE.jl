@testset "Diffusion" begin
    var = Variable(1, "u")

    diffusion = Diffusion(var)

    # Generate shape function and Variable values for a dummy element
    qr = QuadratureRule{2,RefCube}(:legendre, 2)
    func_space = Lagrange{2, RefCube, 1}()
    fe_values = FECellValues(qr, func_space)
    n_qp = length(points(qr))

    # Nodal coordinates
    coords = Vec{2, Float64}[Vec{2}((-1, -1)),
                             Vec{2}((1, -1)),
                             Vec{2}((1, 1)),
                             Vec{2}((-1, 1))]

    reinit!(fe_values, coords)

    nodal_values = [0, 1, 1, 0]

    var.phi = fe_values.N
    var.grad_phi = fe_values.dNdx
    var.JxW = fe_values.detJdV

    var.value = [function_value(fe_values, qp, nodal_values) for qp in 1:n_qp]
    var.grad = [function_gradient(fe_values, qp, nodal_values) for qp in 1:n_qp]

    var.n_dofs = length(nodal_values)
    var.n_qp = n_qp

    residual = zeros(Float64, var.n_dofs)

    # Test the Kernel Interface
    computeResidual!(residual, diffusion)

    # Verified by running the same problem in MOOSE
    for i in 1:length(residual)
        @test residual[i]-[-0.5, 0.5, 0.5, -0.5][i] < 1e-10
    end
end