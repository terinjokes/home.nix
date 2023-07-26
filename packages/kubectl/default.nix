{ lib, buildGoModule, fetchFromGitHub, which, makeWrapper, rsync
, installShellFiles, runtimeShell, nixosTests }:

buildGoModule rec {
  pname = "kubectl";
  version = "1.27.4";

  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "kubernetes";
    rev = "v${version}";
    sha256 = "sha256-Tb+T7kJHyZPXwUcEATj3jBr9qa7Sk6b+wL8HhqFOhYM=";
  };

  vendorSha256 = null;

  doCheck = false;

  nativeBuildInputs = [ makeWrapper which rsync installShellFiles ];

  outputs = [ "out" "man" "convert" ];

  WHAT = lib.concatStringsSep " " [ "cmd/kubectl" "cmd/kubectl-convert" ];

  buildPhase = ''
    runHook preBuild
    substituteInPlace "hack/update-generated-docs.sh" --replace "make" "make SHELL=${runtimeShell}"
    patchShebangs ./hack ./cluster/addons/addon-manager
    make "SHELL=${runtimeShell}" "WHAT=$WHAT"
    ./hack/update-generated-docs.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D _output/local/go/bin/kubectl -t $out/bin
    install -D _output/local/go/bin/kubectl-convert -t $convert/bin
    installManPage docs/man/man1/kubectl*
    installShellCompletion --cmd kubectl \
      --bash <($out/bin/kubectl completion bash) \
      --fish <($out/bin/kubectl completion fish) \
      --zsh <($out/bin/kubectl completion zsh)
    runHook postInstall
  '';

  meta = with lib; {
    description = "Production-Grade Container Scheduling and Management";
    license = licenses.asl20;
    homepage = "https://kubernetes.io";
    maintainers = with maintainers; [ ] ++ teams.kubernetes.members;
    platforms = platforms.linux;
  };

  passthru.tests = nixosTests.kubernetes;
}
